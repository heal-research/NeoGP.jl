
# Work items carry the caller's chosen slot index (`idx`) alongside the individual, and
# results carry it back unchanged. Reproducible for a fixed random seed.
# `maxeval` limits each parameter fit (`nothing`: the optimizer's default), see
# `fit_parameters`.
#
# An exception in a worker closes `resultqueue` and `workqueue` with that
# exception (and its backtrace) before it is rethrown.
#
# Returns the worker tasks; the caller must `close(workqueue)` to stop the
# workers and then join (`wait`) them, which also guarantees that every worker
# has merged its task-local timing into `global_timer` before the next phase.
function start_fitness_eval_workers(workqueue, resultqueue, nthreads, indiv_loss_func, maxeval)
    return [Threads.@spawn begin
        try
            # Reuse the shared interpreter's task-local fit-buffer cache for
            # every individual this worker processes.
            with_fit_buffer_cache() do
                for (indiv, idx) in workqueue
                    @timeit task_timer() "evaluate_loss!" f,fevals = evaluate_loss!(indiv, indiv_loss_func; optimize = true, maxeval)
                    put!(resultqueue, (indiv, f, fevals, idx))
                end
            end
            # Merge this worker's timing into the global timer.  Safe here: the
            # caller only joins the workers after its own `@timeit` blocks.
            merge_task_timer!()
        catch ex
            # The first failure closes both queues with the same exception, so
            # that `take!` in the caller and a pending `put!` of new work both
            # throw it, and the other workers stop.
            err = CapturedException(ex, catch_backtrace())
            isopen(resultqueue) && close(resultqueue, err)
            isopen(workqueue) && close(workqueue, err)
            rethrow()
        end
    end for _ in 1:nthreads]
end

function process_worker_results(action, resultqueue, numresults)
    waitingresults = numresults
    while waitingresults > 0
        action(take!(resultqueue))
        waitingresults -= 1
    end
end