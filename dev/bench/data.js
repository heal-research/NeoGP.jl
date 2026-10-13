window.BENCHMARK_DATA = {
  "lastUpdate": 1791882955958,
  "repoUrl": "https://github.com/heal-research/NeoGP.jl",
  "entries": {
    "NeoGP": [
      {
        "commit": {
          "author": {
            "email": "gabriel.kronberger@heuristiclab.com",
            "name": "Gabriel Kronberger",
            "username": "gkronber"
          },
          "committer": {
            "email": "gabriel.kronberger@heuristiclab.com",
            "name": "Gabriel Kronberger",
            "username": "gkronber"
          },
          "distinct": true,
          "id": "5324f16e4fa52f9bd583bb0d8c3098cd31d8a60a",
          "message": "Initial import of NeoGP.jl v0.1.0",
          "timestamp": "2026-10-13T11:10:58+02:00",
          "tree_id": "28c758ea6257dc1e626996aa13d164bd7ab2821c",
          "url": "https://github.com/heal-research/NeoGP.jl/commit/5324f16e4fa52f9bd583bb0d8c3098cd31d8a60a"
        },
        "date": 1791882955315,
        "tool": "julia",
        "benches": [
          {
            "name": "gaussian likelihood/AIC/Float32 / 500 observations",
            "value": 1092,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float32 / 5000 observations",
            "value": 8086,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float64 / 500 observations",
            "value": 1393,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float64 / 5000 observations",
            "value": 11171,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float32 / 500 observations",
            "value": 1142,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float32 / 5000 observations",
            "value": 7824,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float64 / 500 observations",
            "value": 1462,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float64 / 5000 observations",
            "value": 11131,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float32 / 500 observations",
            "value": 20017,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float32 / 5000 observations",
            "value": 182080,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float64 / 500 observations",
            "value": 24195,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3024\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float64 / 5000 observations",
            "value": 255277,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3024\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float32 / 500 observations",
            "value": 2996,
            "unit": "ns",
            "extra": "gctime=0\nmemory=928\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float32 / 5000 observations",
            "value": 8366,
            "unit": "ns",
            "extra": "gctime=0\nmemory=928\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float64 / 500 observations",
            "value": 2164,
            "unit": "ns",
            "extra": "gctime=0\nmemory=944\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float64 / 5000 observations",
            "value": 13194,
            "unit": "ns",
            "extra": "gctime=0\nmemory=944\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float32 / 500 observations",
            "value": 10038.8,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float32 / 5000 observations",
            "value": 62901.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float64 / 500 observations",
            "value": 10397.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float64 / 5000 observations",
            "value": 113325.7,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/description_length/Float32 / 500 observations",
            "value": 265095,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2816\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/description_length/Float64 / 500 observations",
            "value": 310691,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3920\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/negloglik/Float32 / 500 observations",
            "value": 34014,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/negloglik/Float64 / 500 observations",
            "value": 40676,
            "unit": "ns",
            "extra": "gctime=0\nmemory=208\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/optimize!/Float32 / 500 observations",
            "value": 187813.8,
            "unit": "ns",
            "extra": "gctime=0\nmemory=304\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/optimize!/Float64 / 500 observations",
            "value": 229454.6,
            "unit": "ns",
            "extra": "gctime=0\nmemory=320\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/description_length/Float32 / 500 observations",
            "value": 280083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2816\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/description_length/Float64 / 500 observations",
            "value": 333683,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3920\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/negloglik/Float32 / 500 observations",
            "value": 37570,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/negloglik/Float64 / 500 observations",
            "value": 43932,
            "unit": "ns",
            "extra": "gctime=0\nmemory=208\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/optimize!/Float32 / 500 observations",
            "value": 363644.3,
            "unit": "ns",
            "extra": "gctime=0\nmemory=752\nallocs=18\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/optimize!/Float64 / 500 observations",
            "value": 462491,
            "unit": "ns",
            "extra": "gctime=0\nmemory=784\nallocs=18\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          }
        ]
      }
    ]
  }
}