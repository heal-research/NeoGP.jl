# test cases taken from https://arxiv.org/pdf/2203.13654

@testset "Crowding distance" begin
# Section 3.1.4 Example
    f = [      (0.79, 0.35),  # 1
               (0.40, 0.71),  # 2
               (0.15, 0.014), # 3
               (0.46, 0.82),  # 4 
               (0.28, 0.98),  # 5
               (0.31, 0.74),  # 6 
               (0.82, 0.52),  # 7 
               (0.84, 0.19),  # 8
               (0.85, 0.78),  # 9
               (0.96, 0.83)]  # 10
    fronts = NeoGP.rank_intersect_sort(f)
    @test length(fronts) == 5
    @test fronts[1] == [3]
    @test fronts[2] == [1, 2, 5, 6, 8]
    @test fronts[3] == [4, 7]
    @test fronts[4] == [9]
    @test fronts[5] == [10]
    
    @show cd = NeoGP.crowdingdistance_manhattan(f, fronts)
    @test cd[1] ≈ 1.4439 atol=1e-4
    @test cd[2] ≈ 1.3508 atol=1e-4
    @test cd[3] == Inf # f1
    @test cd[4] == Inf # f3 = [4, 7]
    @test cd[5] == Inf # f2 smallest by obj1
    @test cd[6] ≈ 0.5561 atol=1e-4
    @test cd[7] == Inf # f3 = [4, 7]
    @test cd[8] == Inf # f3 smallest by obj2
    @test cd[9] == Inf # f4
    @test cd[10] == Inf # f5
end