window.BENCHMARK_DATA = {
  "lastUpdate": 1792346310065,
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
      },
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
          "id": "30d5780c2e29b98883ef36769b153b91c1773b43",
          "message": "Try to fix downgrad-compat check action.",
          "timestamp": "2026-10-13T11:50:12+02:00",
          "tree_id": "2c286593a22bbf5d6fed9cb78b56474acea5b8b1",
          "url": "https://github.com/heal-research/NeoGP.jl/commit/30d5780c2e29b98883ef36769b153b91c1773b43"
        },
        "date": 1791885073573,
        "tool": "julia",
        "benches": [
          {
            "name": "gaussian likelihood/AIC/Float32 / 500 observations",
            "value": 931,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float32 / 5000 observations",
            "value": 6029,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float64 / 500 observations",
            "value": 1191,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float64 / 5000 observations",
            "value": 7942,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float32 / 500 observations",
            "value": 871,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float32 / 5000 observations",
            "value": 6079,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float64 / 500 observations",
            "value": 1232,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float64 / 5000 observations",
            "value": 7932,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float32 / 500 observations",
            "value": 16325,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float32 / 5000 observations",
            "value": 133572,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float64 / 500 observations",
            "value": 18829,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3024\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float64 / 5000 observations",
            "value": 157367,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3024\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float32 / 500 observations",
            "value": 1572,
            "unit": "ns",
            "extra": "gctime=0\nmemory=928\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float32 / 5000 observations",
            "value": 8263,
            "unit": "ns",
            "extra": "gctime=0\nmemory=928\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float64 / 500 observations",
            "value": 1943,
            "unit": "ns",
            "extra": "gctime=0\nmemory=944\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float64 / 5000 observations",
            "value": 8794,
            "unit": "ns",
            "extra": "gctime=0\nmemory=944\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float32 / 500 observations",
            "value": 6134.3,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float32 / 5000 observations",
            "value": 49074,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float64 / 500 observations",
            "value": 7369.1,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float64 / 5000 observations",
            "value": 64418.1,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/description_length/Float32 / 500 observations",
            "value": 198178,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2816\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/description_length/Float64 / 500 observations",
            "value": 219651,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3920\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/negloglik/Float32 / 500 observations",
            "value": 27321,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/negloglik/Float64 / 500 observations",
            "value": 38478,
            "unit": "ns",
            "extra": "gctime=0\nmemory=208\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/optimize!/Float32 / 500 observations",
            "value": 149632.4,
            "unit": "ns",
            "extra": "gctime=0\nmemory=304\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/optimize!/Float64 / 500 observations",
            "value": 183648.7,
            "unit": "ns",
            "extra": "gctime=0\nmemory=320\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/description_length/Float32 / 500 observations",
            "value": 211979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2816\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/description_length/Float64 / 500 observations",
            "value": 236346,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3920\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/negloglik/Float32 / 500 observations",
            "value": 30206,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/negloglik/Float64 / 500 observations",
            "value": 35233,
            "unit": "ns",
            "extra": "gctime=0\nmemory=208\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/optimize!/Float32 / 500 observations",
            "value": 272367.3,
            "unit": "ns",
            "extra": "gctime=0\nmemory=752\nallocs=18\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/optimize!/Float64 / 500 observations",
            "value": 362726.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=784\nallocs=18\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          }
        ]
      },
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
          "id": "03d2763476cc5610e725b8bf10dcb1338d0358e3",
          "message": "Link to python bindings.",
          "timestamp": "2026-10-13T16:13:45+02:00",
          "tree_id": "81280d53361de5bd8dec33a1c3d17fc821f829a4",
          "url": "https://github.com/heal-research/NeoGP.jl/commit/03d2763476cc5610e725b8bf10dcb1338d0358e3"
        },
        "date": 1791900893052,
        "tool": "julia",
        "benches": [
          {
            "name": "gaussian likelihood/AIC/Float32 / 500 observations",
            "value": 1533,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float32 / 5000 observations",
            "value": 8416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float64 / 500 observations",
            "value": 1803,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float64 / 5000 observations",
            "value": 13385,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float32 / 500 observations",
            "value": 1583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float32 / 5000 observations",
            "value": 8887,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float64 / 500 observations",
            "value": 1643,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float64 / 5000 observations",
            "value": 14577,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float32 / 500 observations",
            "value": 27271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float32 / 5000 observations",
            "value": 236944,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float64 / 500 observations",
            "value": 43692,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3024\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float64 / 5000 observations",
            "value": 464689,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3024\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float32 / 500 observations",
            "value": 2554,
            "unit": "ns",
            "extra": "gctime=0\nmemory=928\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float32 / 5000 observations",
            "value": 9758,
            "unit": "ns",
            "extra": "gctime=0\nmemory=928\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float64 / 500 observations",
            "value": 2485,
            "unit": "ns",
            "extra": "gctime=0\nmemory=944\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float64 / 5000 observations",
            "value": 14347,
            "unit": "ns",
            "extra": "gctime=0\nmemory=944\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float32 / 500 observations",
            "value": 11337.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float32 / 5000 observations",
            "value": 61535.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float64 / 500 observations",
            "value": 15108.3,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float64 / 5000 observations",
            "value": 85210.4,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/description_length/Float32 / 500 observations",
            "value": 297669,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2816\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/description_length/Float64 / 500 observations",
            "value": 318174,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3920\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/negloglik/Float32 / 500 observations",
            "value": 37330,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/negloglik/Float64 / 500 observations",
            "value": 40665,
            "unit": "ns",
            "extra": "gctime=0\nmemory=208\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/optimize!/Float32 / 500 observations",
            "value": 189542.3,
            "unit": "ns",
            "extra": "gctime=0\nmemory=304\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/optimize!/Float64 / 500 observations",
            "value": 231522.7,
            "unit": "ns",
            "extra": "gctime=0\nmemory=320\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/description_length/Float32 / 500 observations",
            "value": 323595,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2816\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/description_length/Float64 / 500 observations",
            "value": 368161,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3920\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/negloglik/Float32 / 500 observations",
            "value": 38713,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/negloglik/Float64 / 500 observations",
            "value": 44554,
            "unit": "ns",
            "extra": "gctime=0\nmemory=208\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/optimize!/Float32 / 500 observations",
            "value": 362326.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=752\nallocs=18\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/optimize!/Float64 / 500 observations",
            "value": 464954.9,
            "unit": "ns",
            "extra": "gctime=0\nmemory=784\nallocs=18\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          }
        ]
      },
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
          "id": "f570d990a31ae2535cd3902c11ea442b1139be3a",
          "message": "Add funding statement",
          "timestamp": "2026-10-17T12:48:43+02:00",
          "tree_id": "3a94ea7d5cf251d70906fff3fcf2b7fe7d73710b",
          "url": "https://github.com/heal-research/NeoGP.jl/commit/f570d990a31ae2535cd3902c11ea442b1139be3a"
        },
        "date": 1792234395906,
        "tool": "julia",
        "benches": [
          {
            "name": "gaussian likelihood/AIC/Float32 / 500 observations",
            "value": 1132,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float32 / 5000 observations",
            "value": 7795,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float64 / 500 observations",
            "value": 1373,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float64 / 5000 observations",
            "value": 10730,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float32 / 500 observations",
            "value": 1203,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float32 / 5000 observations",
            "value": 7825,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float64 / 500 observations",
            "value": 1342,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float64 / 5000 observations",
            "value": 10660,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float32 / 500 observations",
            "value": 21300,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float32 / 5000 observations",
            "value": 204804,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float64 / 500 observations",
            "value": 25378,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3024\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float64 / 5000 observations",
            "value": 211497,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3024\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float32 / 500 observations",
            "value": 1984,
            "unit": "ns",
            "extra": "gctime=0\nmemory=928\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float32 / 5000 observations",
            "value": 8335,
            "unit": "ns",
            "extra": "gctime=0\nmemory=928\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float64 / 500 observations",
            "value": 2284,
            "unit": "ns",
            "extra": "gctime=0\nmemory=944\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float64 / 5000 observations",
            "value": 12032,
            "unit": "ns",
            "extra": "gctime=0\nmemory=944\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float32 / 500 observations",
            "value": 9598,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float32 / 5000 observations",
            "value": 64460,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float64 / 500 observations",
            "value": 10488.7,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float64 / 5000 observations",
            "value": 83748.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/description_length/Float32 / 500 observations",
            "value": 268895,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2816\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/description_length/Float64 / 500 observations",
            "value": 314250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3920\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/negloglik/Float32 / 500 observations",
            "value": 33863,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/negloglik/Float64 / 500 observations",
            "value": 40136,
            "unit": "ns",
            "extra": "gctime=0\nmemory=208\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/optimize!/Float32 / 500 observations",
            "value": 188325.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=304\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/optimize!/Float64 / 500 observations",
            "value": 228183.3,
            "unit": "ns",
            "extra": "gctime=0\nmemory=320\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/description_length/Float32 / 500 observations",
            "value": 284644,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2816\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/description_length/Float64 / 500 observations",
            "value": 328526,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3920\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/negloglik/Float32 / 500 observations",
            "value": 37611,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/negloglik/Float64 / 500 observations",
            "value": 43381,
            "unit": "ns",
            "extra": "gctime=0\nmemory=208\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/optimize!/Float32 / 500 observations",
            "value": 361201.1,
            "unit": "ns",
            "extra": "gctime=0\nmemory=752\nallocs=18\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/optimize!/Float64 / 500 observations",
            "value": 461157.6,
            "unit": "ns",
            "extra": "gctime=0\nmemory=784\nallocs=18\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          }
        ]
      },
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
          "id": "07458bd61a4b12eca4164a8cbb2f9df2c0c0bcf1",
          "message": "-> v0.1.1",
          "timestamp": "2026-10-18T18:56:12+02:00",
          "tree_id": "ad7d6edd88f4746615db2844cf5c3db7afec6d43",
          "url": "https://github.com/heal-research/NeoGP.jl/commit/07458bd61a4b12eca4164a8cbb2f9df2c0c0bcf1"
        },
        "date": 1792346309291,
        "tool": "julia",
        "benches": [
          {
            "name": "gaussian likelihood/AIC/Float32 / 500 observations",
            "value": 881,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float32 / 5000 observations",
            "value": 6089,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float64 / 500 observations",
            "value": 1142,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/AIC/Float64 / 5000 observations",
            "value": 8823,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float32 / 500 observations",
            "value": 931,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float32 / 5000 observations",
            "value": 6079,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float64 / 500 observations",
            "value": 1152,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/BIC/Float64 / 5000 observations",
            "value": 7922,
            "unit": "ns",
            "extra": "gctime=0\nmemory=176\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float32 / 500 observations",
            "value": 16184,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float32 / 5000 observations",
            "value": 129943,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float64 / 500 observations",
            "value": 18858,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3024\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/description_length/Float64 / 5000 observations",
            "value": 152436,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3024\nallocs=44\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float32 / 500 observations",
            "value": 1543,
            "unit": "ns",
            "extra": "gctime=0\nmemory=928\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float32 / 5000 observations",
            "value": 7140,
            "unit": "ns",
            "extra": "gctime=0\nmemory=928\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float64 / 500 observations",
            "value": 1752,
            "unit": "ns",
            "extra": "gctime=0\nmemory=944\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/fractional_bayes_factor/Float64 / 5000 observations",
            "value": 8662,
            "unit": "ns",
            "extra": "gctime=0\nmemory=944\nallocs=20\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float32 / 500 observations",
            "value": 6208.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float32 / 5000 observations",
            "value": 48994.7,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float64 / 500 observations",
            "value": 7125.6,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "gaussian likelihood/optimize!/Float64 / 5000 observations",
            "value": 79699.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/description_length/Float32 / 500 observations",
            "value": 193997,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2816\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/description_length/Float64 / 500 observations",
            "value": 218635,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3920\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/negloglik/Float32 / 500 observations",
            "value": 27340,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/negloglik/Float64 / 500 observations",
            "value": 32548,
            "unit": "ns",
            "extra": "gctime=0\nmemory=208\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/optimize!/Float32 / 500 observations",
            "value": 150197.6,
            "unit": "ns",
            "extra": "gctime=0\nmemory=304\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp profiled likelihood/optimize!/Float64 / 500 observations",
            "value": 184705.8,
            "unit": "ns",
            "extra": "gctime=0\nmemory=320\nallocs=6\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/description_length/Float32 / 500 observations",
            "value": 212845,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2816\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/description_length/Float64 / 500 observations",
            "value": 242680,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3920\nallocs=45\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/negloglik/Float32 / 500 observations",
            "value": 29984,
            "unit": "ns",
            "extra": "gctime=0\nmemory=160\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/negloglik/Float64 / 500 observations",
            "value": 36554,
            "unit": "ns",
            "extra": "gctime=0\nmemory=208\nallocs=4\nparams={\"evals\":1,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/optimize!/Float32 / 500 observations",
            "value": 273374.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=752\nallocs=18\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          },
          {
            "name": "pow-log-exp scatter likelihood/optimize!/Float64 / 500 observations",
            "value": 365887.3,
            "unit": "ns",
            "extra": "gctime=0\nmemory=784\nallocs=18\nparams={\"evals\":10,\"evals_set\":false,\"gcsample\":false,\"gctrial\":true,\"memory_tolerance\":0.01,\"overhead\":0,\"samples\":5,\"seconds\":5,\"time_tolerance\":0.05}"
          }
        ]
      }
    ]
  }
}