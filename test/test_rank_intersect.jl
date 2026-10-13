# test cases taken from https://arxiv.org/pdf/2203.13654

@testset "Rank Intersect Sorting" begin
    # Section 3.1.4 Example
    f = [[0.79, 0.35],
               [0.40, 0.71],
               [0.15, 0.014],
               [0.46, 0.82],
               [0.28, 0.98],
               [0.31, 0.74],
               [0.82, 0.52],
               [0.84, 0.19],
               [0.85, 0.78],
               [0.96, 0.83]]
    fronts = NeoGP.rank_intersect_sort(f)
    @test length(fronts) == 5
    @test fronts[1] == [3]
    @test fronts[2] == [1, 2, 5, 6, 8]
    @test fronts[3] == [4, 7]
    @test fronts[4] == [9]
    @test fronts[5] == [10]
    
    # a single case
    fronts = NeoGP.rank_intersect_sort([[0.5, 0.5]])
    @test length(fronts) == 1 && fronts[1] == [1]
    
    dom(fi,fj) = all(t -> t[1] <= t[2], zip(fi, fj)) && any(t -> t[1] < t[2], zip(fi, fj))
    nondom(fi, fj) = !(dom(fi,fj) || dom(fj,fi))
   
    function check_fronts_domination(fronts, f)
        for rank in eachindex(fronts)
            for i in fronts[rank]
                for j in fronts[rank]
                    if dom(f[i], f[j]) || dom(f[j], f[i])
                        @error "Found domination within front $rank between individuals $i and $j with fitnesses $(f[i]) and $(f[j])"
                    end
                    @test nondom(f[i], f[j]) # within same rank, no domination
                end
            end
        end
            
        for rank = 1:length(fronts)-1
            for j in fronts[rank+1]
                @test any(i -> dom(f[i], f[j]), fronts[rank]) # at least one in lower rank dominates
            end
        end
    end

    f = [[1, 7], [2, 2], [2, 3], [3, 2], [7,1]]
    fronts = NeoGP.rank_intersect_sort(f)
    @test fronts == [[1,2,5],[3,4]]
    check_fronts_domination(fronts, f)
    
    
    # https://arxiv.org/pdf/2203.13654 Fig 5 shows below 100ms for 2 objectives and 10_000 individuals
    f = [rand(2) for _ in 1:10000]
    NeoGP.rank_intersect_sort(f) # warmup
    @time fronts = NeoGP.rank_intersect_sort(f)

end