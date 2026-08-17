-- San Diego Routes Storage
-- Все маршруты для smart_heist_farm

return {
    -- ============ REMOTES INFO ============
    remotes = {
        bank = {
            name = "BankRobbery",
            methods = {
                StartRobTrolley = "FireServer(trolley)",  -- Начать грабить тележку
            }
        },
        jewelry = {
            name = "JewelleryStoreService",
            methods = {
                BeginCabinet = "InvokeServer(cabinet)",  -- Начать грабеж витрины
                HitCabinet = "InvokeServer(cabinet)",     -- Бить витрину
                GrabItem = "InvokeServer(item)",          -- Взять предмет
                StopCabinet = "FireServer(cabinet)",      -- Остановить
            }
        },
    },
    -- ============ BOAT MISSION ROUTE ============
    boat_mission = {
        name = "Boat Mission Route",
        description = "От лодочного NPC до boat_end",
        waypoints = {
            Vector3.new(7283.80, 11.30, 1580.56),
            Vector3.new(6975.95, 9.72, 2058.30),
            Vector3.new(6378.61, 9.23, 2459.66),
            Vector3.new(5279.79, 8.78, 2330.06),
            Vector3.new(4221.86, 8.80, 2422.23),
            Vector3.new(1800.29, 8.22, 2036.91),
            Vector3.new(-749.39, 10.04, 1783.75),
            Vector3.new(-921.56, 9.58, 1469.81),
        }
    },

    truck_mission = {
        name = "Truck Mission Route",
        description = "Маршрут грузовика с noclip+fly постоянно",
        always_fly_noclip = true,  -- Всегда fly+noclip на грузовике
        teleport_segment = {from = 11, to = 12},  -- Точки 11-12: телепорт через стену
        connect_to = "bank_jewelry_to_el_capo",  -- Подключается к банковскому маршруту
        connect_at_point = 6,  -- Подключается к точке 6

        -- Точки сдачи товара (стоять 6 секунд)
        -- Игра генерирует точки доставки случайно, сохранены первые 3 уровня
        delivery_points = {
            {level = 1, name = "Autoshop", waypoint = 33, pos = Vector3.new(-164.38, 17.75, 456.65)},
            {level = 2, name = "TacoHell", waypoint = 6, pos = Vector3.new(13.90, 17.22, 276.28)},
            {level = 3, name = "Gym", waypoint = 6, pos = Vector3.new(103.00, 17.00, 267.00)},
            -- Уровни 4-7: игра генерирует точки случайно
        },
        delivery_wait_time = 6,  -- Секунды ожидания на точке сдачи

        -- Маршруты для разных уровней миссии
        level_routes = {
            -- Уровень 1: полный маршрут (основной)
            [1] = {
                start_point = Vector3.new(7062.82, 20.33, 236.38),  -- Точка старта миссии
                waypoints = {
                    Vector3.new(7062.82, 20.33, 236.38),   -- 1 В грузовике
                    Vector3.new(6806.96, 19.55, 222.22),   -- 2
                    Vector3.new(6576.45, 20.51, 153.95),   -- 3
                    Vector3.new(6339.10, 26.64, 233.10),   -- 4
                    Vector3.new(6211.61, 40.02, 330.24),   -- 5
                    Vector3.new(6079.55, 54.62, 461.99),   -- 6
                    Vector3.new(5795.00, 52.55, 435.31),   -- 7
                    Vector3.new(5542.29, 38.92, 403.94),   -- 8
                    Vector3.new(5366.34, 15.94, 381.00),   -- 9
                    Vector3.new(4962.85, 23.63, 319.43),   -- 10
                    Vector3.new(4879.28, 90.85, 257.58),   -- 11 TELEPORT START
                    Vector3.new(4436.82, 85.81, 172.54),   -- 12 TELEPORT END
                    Vector3.new(4371.91, 18.83, 191.24),   -- 13
                    Vector3.new(3974.81, 19.67, 177.86),   -- 14
                    Vector3.new(3762.47, 20.51, 193.30),   -- 15
                    Vector3.new(3430.65, 34.02, 222.70),   -- 16
                    Vector3.new(3334.62, 21.78, 230.72),   -- 17
                    Vector3.new(3205.83, 21.01, 241.84),   -- 18
                    Vector3.new(3072.17, 22.60, 423.11),   -- 19
                    Vector3.new(2748.73, 18.66, 472.93),   -- 20
                    Vector3.new(2462.20, 17.90, 458.27),   -- 21
                    Vector3.new(2173.94, 20.98, 439.15),   -- 22
                    Vector3.new(1957.19, 42.93, 457.95),   -- 23
                    Vector3.new(1360.27, 45.53, 506.11),   -- 24
                    Vector3.new(1142.98, 47.01, 489.99),   -- 25
                    Vector3.new(983.62, 43.63, 507.37),    -- 26
                    Vector3.new(880.38, 25.42, 489.58),    -- 27
                    Vector3.new(443.82, 24.68, 455.79),    -- 28
                    Vector3.new(352.07, 28.65, 455.96),    -- 29 CHECKPOINT для уровней 2 и 3
                    Vector3.new(162.64, 15.41, 452.35),    -- 30
                    Vector3.new(66.46, 17.37, 377.67),     -- 31
                    Vector3.new(-129.71, 17.42, 380.16),   -- 32
                    Vector3.new(-164.38, 17.75, 456.65),   -- 33 DELIVERY POINT 1
                    Vector3.new(-99.45, 17.02, 112.08),    -- 34
                    Vector3.new(-128.62, 18.76, 6.47),     -- 35
                    Vector3.new(-121.06, 17.85, -369.87),  -- 36
                    Vector3.new(544.25, 17.17, -375.28),   -- 37
                    Vector3.new(533.44, 17.66, -567.21),   -- 38 Конец
                }
            },

            -- Уровень 2: короткий маршрут до checkpoint, потом основной
            [2] = {
                start_point = Vector3.new(7062.82, 20.33, 236.38),
                waypoints = {
                    Vector3.new(333.76, 30.24, 449.56),    -- 1 От старта
                    Vector3.new(218.20, 16.96, 415.50),    -- 2
                    Vector3.new(149.30, 16.88, 359.50),    -- 3
                    Vector3.new(5.04, 18.08, 271.99),      -- 4
                    Vector3.new(2.16, 19.42, 184.49),      -- 5
                    Vector3.new(-123.43, 17.03, 5.97),     -- 6 DELIVERY POINT 2 + подключение к основному
                },
                connects_to_level = 1,  -- Подключается к уровню 1
                connects_at_waypoint = 35  -- Подключается к точке 35 основного маршрута
            },

            -- Уровень 3: короткий маршрут до checkpoint, потом основной
            [3] = {
                start_point = Vector3.new(7062.82, 20.33, 236.38),
                waypoints = {
                    Vector3.new(339.06, 30.34, 451.55),    -- 1 От старта
                    Vector3.new(228.36, 15.96, 401.97),    -- 2
                    Vector3.new(109.04, 17.92, 365.13),    -- 3
                    Vector3.new(100.25, 16.28, 264.22),    -- 4
                    Vector3.new(40.49, 17.58, 156.97),     -- 5
                    Vector3.new(-115.97, 17.86, 15.99),    -- 6 DELIVERY POINT 3 + подключение к основному
                },
                connects_to_level = 1,  -- Подключается к уровню 1
                connects_at_waypoint = 35  -- Подключается к точке 35 основного маршрута
            },
        },

        waypoints = nil,  -- Не используется, маршруты в level_routes
    },

    -- ============ SPAWN TO MISSIONS ============
    spawn_to_boat_npc = {
        name = "Spawn to Boat NPC",
        description = "От спавна до лодочного NPC",
        fly_until = 8,  -- До точки 8 включительно использовать fly + noclip
        walk_from = 9,  -- С точки 9 идти пешком
        waypoints = {
            Vector3.new(6887.37, 18.04, 40.18),
            Vector3.new(6768.60, 39.91, 306.71),
            Vector3.new(6760.57, 43.07, 368.51),
            Vector3.new(6808.91, 32.44, 504.17),
            Vector3.new(7148.67, 29.80, 783.81),
            Vector3.new(7269.80, 25.81, 951.46),
            Vector3.new(7276.47, 29.67, 1040.19),
            Vector3.new(7279.41, 20.00, 1139.58),  -- Точка 8 - последняя с fly
            Vector3.new(7278.83, 16.88, 1343.00),  -- Точка 9 - начало ходьбы
            Vector3.new(7282.30, 16.57, 1502.38),
            Vector3.new(7300.29, 18.00, 1502.64),
        }
    },

    spawn_to_truck_mission = {
        name = "Spawn to Truck Mission",
        description = "От спавна до грузовика",
        waypoints = {
            Vector3.new(6886.39, 19.20, 22.16),
            Vector3.new(6961.81, 19.88, 127.22),
            Vector3.new(7124.35, 21.33, 233.73),
        }
    },

    spawn_to_jewelry = {
        name = "Spawn to Jewelry Store",
        description = "От спавна до ювелирки с грабежом витрин",
        fly_to_safe = true,  -- Летать к safe месту на высоте
        jewelry_cases = {
            Vector3.new(-28.35, 18.81, 900.27),
            Vector3.new(-48.08, 18.81, 900.50),
            Vector3.new(-57.78, 19.30, 895.37),
            Vector3.new(-57.78, 19.30, 941.95),
            Vector3.new(-28.51, 19.09, 945.15),
            Vector3.new(-48.08, 18.81, 945.15),
            Vector3.new(-57.78, 19.30, 951.02),
            Vector3.new(-57.78, 19.30, 904.55),
        },
        waypoints = {
            Vector3.new(6901.40, 19.74, 77.69),   -- 1 Спавн
            Vector3.new(6422.13, 18.91, 158.56),  -- 2
            Vector3.new(-114.48, 18.54, 160.28),  -- 3
            Vector3.new(-110.64, 18.57, 747.43),  -- 4 Проверка охраны
            -- Тут грабить витрины jewelry_cases
            Vector3.new(-199.92, 78.46, 931.56),  -- 5 Fly вверх к safe месту (Y=78)
        }
    },

    spawn_to_bank = {
        name = "Spawn to Bank",
        description = "От спавна до банка с грабежом тележек",
        waypoints = {
            Vector3.new(6894.32, 20.37, 87.54),
            Vector3.new(-111.54, 17.31, 86.23),
            Vector3.new(-114.38, 17.90, -221.50),
            Vector3.new(-246.81, 18.44, -224.20),
            Vector3.new(-246.18, 16.82, -292.19),
            Vector3.new(-192.54, 0.74, -289.76),
            Vector3.new(-191.09, 0.70, -270.55),
            Vector3.new(-267.91, 1.08, -272.10),
            Vector3.new(-287.80, 0.31, -272.77),  -- 9 Зона тележек - проверка
            Vector3.new(-287.36, -0.52, -301.56),
            Vector3.new(-287.81, -0.47, -242.03), -- 11 Зона тележек - проверка
            Vector3.new(-285.89, 0.49, -271.12),
            Vector3.new(-192.77, 0.71, -272.80),
            Vector3.new(-192.34, 1.03, -287.99),
            Vector3.new(-241.87, 18.78, -289.85),
            Vector3.new(-245.46, 19.01, -223.25),
        },
        trolley_check_waypoints = {9, 11},  -- На этих точках проверять тележки
    },

    -- ============ ДРУГИЕ МАРШРУТЫ ============
    jewelry_to_bank_route = {
        name = "Jewelry Safe to Bank Route",
        description = "От safe места Jewelry к маршруту банка",
        connect_to = "bank_jewelry_to_el_capo",  -- Соединяется с маршрутом банка
        connect_at_point = 4,  -- Подключается к точке 4 или 5 маршрута банка
        waypoints = {
            Vector3.new(-199.92, 78.46, 931.56),  -- 1 Jewelry safe место
            Vector3.new(-197.63, 78.21, 888.55),  -- 2
            Vector3.new(-266.53, 21.01, 711.74),  -- 3
            Vector3.new(-377.79, 23.45, 380.26),  -- 4
            Vector3.new(-149.35, 19.76, -64.29),  -- 5
            Vector3.new(-55.08, 33.44, -481.34),  -- 6 Конец - идёт к точке 4 банка
        }
    },

    bank_jewelry_to_el_capo = {
        name = "Bank/Jewelry to El Capo Cash Drop",
        description = "Маршрут сдачи кэша в El Capo",
        teleport_segment = {from = 12, to = 13},  -- Точки 12-13: телепорт через стену с fly+noclip
        walk_from = 14,  -- С точки 14 идти пешком
        waypoints = {
            Vector3.new(-247.43, 18.56, -219.27),   -- 1 Bank exit
            Vector3.new(-107.91, 19.63, -261.07),   -- 2
            Vector3.new(-29.36, 20.17, -346.53),    -- 3
            Vector3.new(481.35, 30.08, -148.83),    -- 4 << Jewelry подключается сюда
            Vector3.new(910.39, 43.39, -181.42),    -- 5
            Vector3.new(1781.94, 41.03, -185.93),   -- 6
            Vector3.new(2590.47, 40.85, -592.71),   -- 7
            Vector3.new(2929.97, 23.35, -559.45),   -- 8
            Vector3.new(2940.94, 23.98, -564.33),   -- 9
            Vector3.new(3241.67, 40.34, -610.12),   -- 10
            Vector3.new(3937.36, 56.60, -452.21),   -- 11
            Vector3.new(4396.94, 94.47, -378.02),   -- 12 TELEPORT START (fly+noclip ON)
            Vector3.new(4863.64, 101.37, -353.32),  -- 13 TELEPORT END (через стену)
            Vector3.new(5532.85, 33.52, -159.57),   -- 14 Walk start (fly+noclip OFF)
            Vector3.new(6461.78, 64.20, -343.80),   -- 15
            Vector3.new(6477.46, 64.15, -332.67),   -- 16
            Vector3.new(6482.20, 64.78, -306.13),   -- 17
            Vector3.new(6546.83, 66.38, -299.37),   -- 18
            Vector3.new(6599.20, 67.87, -406.06),   -- 19
            Vector3.new(6599.32, 68.14, -442.94),   -- 20
            Vector3.new(6599.84, 80.68, -482.28),   -- 21
            Vector3.new(6580.07, 80.68, -480.25),   -- 22
            Vector3.new(6581.55, 96.58, -437.92),   -- 23
            Vector3.new(6555.37, 93.33, -440.94),   -- 24 El Capo cash drop
        }
    },
}
