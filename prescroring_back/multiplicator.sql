CREATE TABLE company_features (
    inn text,
    company_age integer,
    num_employees integer,
    tax_debt numeric,
    paid_taxes numeric,
    tax_debt_ratio numeric,
    has_state_support integer,
    has_mass_founder boolean,
    total_assets numeric,
    equity numeric,
    current_assets numeric,
    inventories numeric,
    current_liabilities numeric,
    total_liabilities numeric,
    revenue numeric,
    net_profit numeric,
    revenue_prev numeric,
    current_ratio numeric,
    quick_ratio numeric,
    debt_to_equity numeric,
    debt_to_assets numeric,
    roa numeric,
    roe numeric,
    gross_margin numeric,
    net_margin numeric,
    revenue_growth numeric,
    revenue_cagr_3y numeric,
    revenue_cagr_5y numeric,
    roa_avg_3y numeric,
    roa_avg_5y numeric,
    roa_std_3y numeric,
    roa_std_5y numeric,
    debt_to_equity_avg_3y numeric,
    debt_to_equity_avg_5y numeric,
    debt_to_equity_trend_3y numeric,
    debt_to_equity_trend_5y numeric
);

CREATE TABLE features_test (
    inn text,
    company_age integer,
    num_employees integer,
    tax_debt numeric,
    paid_taxes numeric,
    tax_debt_ratio numeric,
    has_state_support integer,
    has_mass_founder boolean,
    total_assets numeric,
    equity numeric,
    current_assets numeric,
    inventories numeric,
    current_liabilities numeric,
    total_liabilities numeric,
    revenue numeric,
    net_profit numeric,
    revenue_prev numeric,
    current_ratio numeric,
    quick_ratio numeric,
    debt_to_equity numeric,
    debt_to_assets numeric,
    roa numeric,
    roe numeric,
    gross_margin numeric,
    net_margin numeric,
    revenue_growth numeric,
    revenue_cagr_3y numeric,
    revenue_cagr_5y numeric,
    roa_avg_3y numeric,
    roa_avg_5y numeric,
    roa_std_3y numeric,
    roa_std_5y numeric,
    debt_to_equity_avg_3y numeric,
    debt_to_equity_avg_5y numeric,
    debt_to_equity_trend_3y numeric,
    debt_to_equity_trend_5y numeric
);

-- Вставка данных с моментальными и долгосрочными признаками
WITH moment_features AS (
    -- Моментальные признаки (без агрегации)
    SELECT
        e.inn,
        CASE
            WHEN COALESCE(e.data -> 'data' ->> 'ДатаОГРН', '') <> ''
                 AND SUBSTRING(e.data -> 'data' ->> 'ДатаОГРН' FROM 1 FOR 4) ~ '^[0-9]{4}$'
            THEN 2025 - CAST(SUBSTRING(e.data -> 'data' ->> 'ДатаОГРН' FROM 1 FOR 4) AS INTEGER)
            ELSE NULL
        END AS company_age,
        COALESCE(
            CASE
                WHEN COALESCE(e.data -> 'data' ->> 'СЧР', '') ~ '^[0-9]+$' THEN (e.data -> 'data' ->> 'СЧР')::integer
                ELSE NULL
            END,
            0
        ) AS num_employees,
        COALESCE(
            CASE
                WHEN COALESCE(e.data -> 'data' -> 'Налоги' ->> 'СумНедоим', '') ~ '^[0-9]+(\.[0-9]+)?$' THEN (e.data -> 'data' -> 'Налоги' ->> 'СумНедоим')::numeric
                ELSE 0
            END,
            0
        ) AS tax_debt,
        COALESCE(
            CASE
                WHEN COALESCE(e.data -> 'data' -> 'Налоги' ->> 'СумУпл', '') ~ '^[0-9]+(\.[0-9]+)?$' THEN (e.data -> 'data' -> 'Налоги' ->> 'СумУпл')::numeric
                ELSE 0
            END,
            0
        ) AS paid_taxes,
        CASE
            WHEN COALESCE(
                    CASE
                        WHEN COALESCE(e.data -> 'data' -> 'Налоги' ->> 'СумУпл', '') ~ '^[0-9]+(\.[0-9]+)?$' THEN (e.data -> 'data' -> 'Налоги' ->> 'СумУпл')::numeric
                        ELSE 0
                    END,
                    0
                 ) > 0
            THEN COALESCE(
                    CASE
                        WHEN COALESCE(e.data -> 'data' -> 'Налоги' ->> 'СумНедоим', '') ~ '^[0-9]+(\.[0-9]+)?$' THEN (e.data -> 'data' -> 'Налоги' ->> 'СумНедоим')::numeric
                        ELSE 0
                    END,
                    0
                 ) /
                 COALESCE(
                    CASE
                        WHEN COALESCE(e.data -> 'data' -> 'Налоги' ->> 'СумУпл', '') ~ '^[0-9]+(\.[0-9]+)?$' THEN (e.data -> 'data' -> 'Налоги' ->> 'СумУпл')::numeric
                        ELSE 0
                    END
                 )
            ELSE NULL
        END AS tax_debt_ratio,
        CASE
            WHEN jsonb_array_length(COALESCE(e.data -> 'data' -> 'ПоддержМСП', '[]'::jsonb)) > 0 THEN 1
            ELSE 0
        END AS has_state_support,
        COALESCE(
            EXISTS (
                SELECT 1
                FROM jsonb_array_elements(COALESCE(e.data -> 'data' -> 'Учред' -> 'ФЛ', '[]'::jsonb)) AS founder
                WHERE COALESCE((founder ->> 'МассУчред')::boolean, false) = true
            ),
            false
        ) AS has_mass_founder,
        (f.data -> 'data' -> '2023' -> '1600' ->> 'СумОтч')::numeric AS total_assets,
        (f.data -> 'data' -> '2023' -> '1300' ->> 'СумОтч')::numeric AS equity,
        (f.data -> 'data' -> '2023' -> '1200' ->> 'СумОтч')::numeric AS current_assets,
        (f.data -> 'data' -> '2023' -> '1210' ->> 'СумОтч')::numeric AS inventories,
        (f.data -> 'data' -> '2023' -> '1500' ->> 'СумОтч')::numeric AS current_liabilities,
        COALESCE((f.data -> 'data' -> '2023' -> '1400' ->> 'СумОтч')::numeric, 0) +
        (f.data -> 'data' -> '2023' -> '1500' ->> 'СумОтч')::numeric AS total_liabilities,
        (f.data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric AS revenue,
        (f.data -> 'data' -> '2023' -> '2400' ->> 'СумОтч')::numeric AS net_profit,
        (f.data -> 'data' -> '2022' -> '2110' ->> 'СумОтч')::numeric AS revenue_prev,
        CASE WHEN (f.data -> 'data' -> '2023' -> '1500' ->> 'СумОтч')::numeric > 0
             THEN (f.data -> 'data' -> '2023' -> '1200' ->> 'СумОтч')::numeric /
                  (f.data -> 'data' -> '2023' -> '1500' ->> 'СумОтч')::numeric
             ELSE NULL
        END AS current_ratio,
        CASE WHEN (f.data -> 'data' -> '2023' -> '1500' ->> 'СумОтч')::numeric > 0
             THEN ((f.data -> 'data' -> '2023' -> '1200' ->> 'СумОтч')::numeric -
                   (f.data -> 'data' -> '2023' -> '1210' ->> 'СумОтч')::numeric) /
                  (f.data -> 'data' -> '2023' -> '1500' ->> 'СумОтч')::numeric
             ELSE NULL
        END AS quick_ratio,
        CASE WHEN (f.data -> 'data' -> '2023' -> '1300' ->> 'СумОтч')::numeric != 0
             THEN (COALESCE((f.data -> 'data' -> '2023' -> '1400' ->> 'СумОтч')::numeric, 0) +
                   (f.data -> 'data' -> '2023' -> '1500' ->> 'СумОтч')::numeric) /
                  (f.data -> 'data' -> '2023' -> '1300' ->> 'СумОтч')::numeric
             ELSE NULL
        END AS debt_to_equity,
        CASE WHEN (f.data -> 'data' -> '2023' -> '1600' ->> 'СумОтч')::numeric > 0
             THEN (COALESCE((f.data -> 'data' -> '2023' -> '1400' ->> 'СумОтч')::numeric, 0) +
                   (f.data -> 'data' -> '2023' -> '1500' ->> 'СумОтч')::numeric) /
                  (f.data -> 'data' -> '2023' -> '1600' ->> 'СумОтч')::numeric
             ELSE NULL
        END AS debt_to_assets,
        CASE WHEN (f.data -> 'data' -> '2023' -> '1600' ->> 'СумОтч')::numeric > 0
             THEN (f.data -> 'data' -> '2023' -> '2400' ->> 'СумОтч')::numeric /
                  (f.data -> 'data' -> '2023' -> '1600' ->> 'СумОтч')::numeric
             ELSE NULL
        END AS roa,
        CASE WHEN (f.data -> 'data' -> '2023' -> '1300' ->> 'СумОтч')::numeric != 0
             THEN (f.data -> 'data' -> '2023' -> '2400' ->> 'СумОтч')::numeric /
                  (f.data -> 'data' -> '2023' -> '1300' ->> 'СумОтч')::numeric
             ELSE NULL
        END AS roe,
        CASE WHEN (f.data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric > 0
             THEN ((f.data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric -
                   (f.data -> 'data' -> '2023' -> '2120' ->> 'СумОтч')::numeric) /
                  (f.data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric
             ELSE NULL
        END AS gross_margin,
        CASE WHEN (f.data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric > 0
             THEN (f.data -> 'data' -> '2023' -> '2400' ->> 'СумОтч')::numeric /
                  (f.data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric
             ELSE NULL
        END AS net_margin,
        CASE WHEN (f.data -> 'data' -> '2022' -> '2110' ->> 'СумОтч')::numeric > 0
             THEN ((f.data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric -
                   (f.data -> 'data' -> '2022' -> '2110' ->> 'СумОтч')::numeric) /
                  (f.data -> 'data' -> '2022' -> '2110' ->> 'СумОтч')::numeric
             ELSE NULL
        END AS revenue_growth
    FROM __egrul_data e
    LEFT JOIN __finances_data f ON e.inn = f.inn
),
cagr_features AS (
    -- CAGR признаки (без агрегации по годам)
    SELECT
        f.inn,
        CASE
            WHEN (f.data -> 'data' -> '2020' -> '2110' ->> 'СумОтч')::numeric > 0
            THEN POWER(
                    (f.data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric /
                    (f.data -> 'data' -> '2020' -> '2110' ->> 'СумОтч')::numeric,
                    1.0 / 3.0
                 ) - 1
            ELSE NULL
        END AS revenue_cagr_3y,
        CASE
            WHEN (f.data -> 'data' -> '2018' -> '2110' ->> 'СумОтч')::numeric > 0
            THEN POWER(
                    (f.data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric /
                    (f.data -> 'data' -> '2018' -> '2110' ->> 'СумОтч')::numeric,
                    1.0 / 5.0
                 ) - 1
            ELSE NULL
        END AS revenue_cagr_5y
    FROM __finances_data f
),
long_term_features AS (
    -- Долгосрочные признаки с агрегацией по годам
    SELECT
        f.inn,
        -- Средняя ROA за 3 года (2020–2023)
        AVG(
            CASE
                WHEN (f.data -> 'data' -> year -> '1600' ->> 'СумОтч')::numeric > 0
                THEN (f.data -> 'data' -> year -> '2400' ->> 'СумОтч')::numeric /
                     (f.data -> 'data' -> year -> '1600' ->> 'СумОтч')::numeric
                ELSE NULL
            END
        ) FILTER (WHERE year IN ('2020', '2021', '2022', '2023')) AS roa_avg_3y,
        -- Средняя ROA за 5 лет (2018–2023)
        AVG(
            CASE
                WHEN (f.data -> 'data' -> year -> '1600' ->> 'СумОтч')::numeric > 0
                THEN (f.data -> 'data' -> year -> '2400' ->> 'СумОтч')::numeric /
                     (f.data -> 'data' -> year -> '1600' ->> 'СумОтч')::numeric
                ELSE NULL
            END
        ) FILTER (WHERE year IN ('2018', '2019', '2020', '2021', '2022', '2023')) AS roa_avg_5y,
        -- Стандартное отклонение ROA за 3 года
        STDDEV(
            CASE
                WHEN (f.data -> 'data' -> year -> '1600' ->> 'СумОтч')::numeric > 0
                THEN (f.data -> 'data' -> year -> '2400' ->> 'СумОтч')::numeric /
                     (f.data -> 'data' -> year -> '1600' ->> 'СумОтч')::numeric
                ELSE NULL
            END
        ) FILTER (WHERE year IN ('2020', '2021', '2022', '2023')) AS roa_std_3y,
        -- Стандартное отклонение ROA за 5 лет
        STDDEV(
            CASE
                WHEN (f.data -> 'data' -> year -> '1600' ->> 'СумОтч')::numeric > 0
                THEN (f.data -> 'data' -> year -> '2400' ->> 'СумОтч')::numeric /
                     (f.data -> 'data' -> year -> '1600' ->> 'СумОтч')::numeric
                ELSE NULL
            END
        ) FILTER (WHERE year IN ('2018', '2019', '2020', '2021', '2022', '2023')) AS roa_std_5y,
        -- Среднее Debt-to-Equity за 3 года
        AVG(
            CASE
                WHEN (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric != 0
                THEN (COALESCE((f.data -> 'data' -> year -> '1400' ->> 'СумОтч')::numeric, 0) +
                      (f.data -> 'data' -> year -> '1500' ->> 'СумОтч')::numeric) /
                     (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric
                ELSE NULL
            END
        ) FILTER (WHERE year IN ('2020', '2021', '2022', '2023')) AS debt_to_equity_avg_3y,
        -- Среднее Debt-to-Equity за 5 лет
        AVG(
            CASE
                WHEN (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric != 0
                THEN (COALESCE((f.data -> 'data' -> year -> '1400' ->> 'СумОтч')::numeric, 0) +
                      (f.data -> 'data' -> year -> '1500' ->> 'СумОтч')::numeric) /
                     (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric
                ELSE NULL
            END
        ) FILTER (WHERE year IN ('2018', '2019', '2020', '2021', '2022', '2023')) AS debt_to_equity_avg_5y,
        -- Тренд Debt-to-Equity за 3 года (линейный коэффициент наклона)
        CASE
            WHEN COUNT(*) FILTER (WHERE year IN ('2020', '2021', '2022', '2023') AND
                                 (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric != 0) = 4
            THEN (
                4 * SUM(
                    CASE
                        WHEN year = '2020' THEN 1
                        WHEN year = '2021' THEN 2
                        WHEN year = '2022' THEN 3
                        WHEN year = '2023' THEN 4
                    END *
                    CASE
                        WHEN (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric != 0
                        THEN (COALESCE((f.data -> 'data' -> year -> '1400' ->> 'СумОтч')::numeric, 0) +
                              (f.data -> 'data' -> year -> '1500' ->> 'СумОтч')::numeric) /
                             (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric
                        ELSE NULL
                    END
                ) -
                SUM(
                    CASE
                        WHEN year = '2020' THEN 1
                        WHEN year = '2021' THEN 2
                        WHEN year = '2022' THEN 3
                        WHEN year = '2023' THEN 4
                    END
                ) *
                SUM(
                    CASE
                        WHEN (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric != 0
                        THEN (COALESCE((f.data -> 'data' -> year -> '1400' ->> 'СумОтч')::numeric, 0) +
                              (f.data -> 'data' -> year -> '1500' ->> 'СумОтч')::numeric) /
                             (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric
                        ELSE NULL
                    END
                )
            ) /
            (
                4 * SUM(
                    CASE
                        WHEN year = '2020' THEN 1
                        WHEN year = '2021' THEN 2
                        WHEN year = '2022' THEN 3
                        WHEN year = '2023' THEN 4
                    END *
                    CASE
                        WHEN year = '2020' THEN 1
                        WHEN year = '2021' THEN 2
                        WHEN year = '2022' THEN 3
                        WHEN year = '2023' THEN 4
                    END
                ) -
                POWER(
                    SUM(
                        CASE
                            WHEN year = '2020' THEN 1
                            WHEN year = '2021' THEN 2
                            WHEN year = '2022' THEN 3
                            WHEN year = '2023' THEN 4
                        END
                    ),
                    2
                )
            )
            ELSE NULL
        END AS debt_to_equity_trend_3y,
        -- Тренд Debt-to-Equity за 5 лет
        CASE
            WHEN COUNT(*) FILTER (WHERE year IN ('2018', '2019', '2020', '2021', '2022', '2023') AND
                                 (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric != 0) = 6
            THEN (
                6 * SUM(
                    CASE
                        WHEN year = '2018' THEN 1
                        WHEN year = '2019' THEN 2
                        WHEN year = '2020' THEN 3
                        WHEN year = '2021' THEN 4
                        WHEN year = '2022' THEN 5
                        WHEN year = '2023' THEN 6
                    END *
                    CASE
                        WHEN (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric != 0
                        THEN (COALESCE((f.data -> 'data' -> year -> '1400' ->> 'СумОтч')::numeric, 0) +
                              (f.data -> 'data' -> year -> '1500' ->> 'СумОтч')::numeric) /
                             (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric
                        ELSE NULL
                    END
                ) -
                SUM(
                    CASE
                        WHEN year = '2018' THEN 1
                        WHEN year = '2019' THEN 2
                        WHEN year = '2020' THEN 3
                        WHEN year = '2021' THEN 4
                        WHEN year = '2022' THEN 5
                        WHEN year = '2023' THEN 6
                    END
                ) *
                SUM(
                    CASE
                        WHEN (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric != 0
                        THEN (COALESCE((f.data -> 'data' -> year -> '1400' ->> 'СумОтч')::numeric, 0) +
                              (f.data -> 'data' -> year -> '1500' ->> 'СумОтч')::numeric) /
                             (f.data -> 'data' -> year -> '1300' ->> 'СумОтч')::numeric
                        ELSE NULL
                    END
                )
            ) /
            (
                6 * SUM(
                    CASE
                        WHEN year = '2018' THEN 1
                        WHEN year = '2019' THEN 2
                        WHEN year = '2020' THEN 3
                        WHEN year = '2021' THEN 4
                        WHEN year = '2022' THEN 5
                        WHEN year = '2023' THEN 6
                    END *
                    CASE
                        WHEN year = '2018' THEN 1
                        WHEN year = '2019' THEN 2
                        WHEN year = '2020' THEN 3
                        WHEN year = '2021' THEN 4
                        WHEN year = '2022' THEN 5
                        WHEN year = '2023' THEN 6
                    END
                ) -
                POWER(
                    SUM(
                        CASE
                            WHEN year = '2018' THEN 1
                            WHEN year = '2019' THEN 2
                            WHEN year = '2020' THEN 3
                            WHEN year = '2021' THEN 4
                            WHEN year = '2022' THEN 5
                            WHEN year = '2023' THEN 6
                        END
                    ),
                    2
                )
            )
            ELSE NULL
        END AS debt_to_equity_trend_5y
    FROM __finances_data f
    CROSS JOIN LATERAL (
        SELECT unnest(ARRAY['2018', '2019', '2020', '2021', '2022', '2023']) AS year
    ) years
    WHERE f.data -> 'data' ? year
    GROUP BY f.inn
)
-- Объединение моментальных и долгосрочных признаков
INSERT INTO features_test
SELECT
    m.inn,
    m.company_age,
    m.num_employees,
    m.tax_debt,
    m.paid_taxes,
    m.tax_debt_ratio,
    m.has_state_support,
    m.has_mass_founder,
    m.total_assets,
    m.equity,
    m.current_assets,
    m.inventories,
    m.current_liabilities,
    m.total_liabilities,
    m.revenue,
    m.net_profit,
    m.revenue_prev,
    m.current_ratio,
    m.quick_ratio,
    m.debt_to_equity,
    m.debt_to_assets,
    m.roa,
    m.roe,
    m.gross_margin,
    m.net_margin,
    m.revenue_growth,
    c.revenue_cagr_3y,
    c.revenue_cagr_5y,
    l.roa_avg_3y,
    l.roa_avg_5y,
    l.roa_std_3y,
    l.roa_std_5y,
    l.debt_to_equity_avg_3y,
    l.debt_to_equity_avg_5y,
    l.debt_to_equity_trend_3y,
    l.debt_to_equity_trend_5y
FROM moment_features m
LEFT JOIN cagr_features c ON m.inn = c.inn
LEFT JOIN long_term_features l ON m.inn = l.inn;

SELECT
    f.inn,
    (f.data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric AS revenue_2023,
    (f.data -> 'data' -> '2020' -> '2110' ->> 'СумОтч')::numeric AS revenue_2020,
    (f.data -> 'data' -> '2018' -> '2110' ->> 'СумОтч')::numeric AS revenue_2018
FROM __finances_data f
WHERE (f.data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric < 0
   OR (f.data -> 'data' -> '2020' -> '2110' ->> 'СумОтч')::numeric < 0
   OR (f.data -> 'data' -> '2018' -> '2110' ->> 'СумОтч')::numeric < 0
LIMIT 10;

UPDATE __finances_data
SET data = jsonb_set(
    data,
    '{data,2023,2110,СумОтч}',
    to_jsonb(ABS((data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric)::text)
)
WHERE (data -> 'data' -> '2023' -> '2110' ->> 'СумОтч')::numeric < 0;


SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN inn IS NULL THEN 1 ELSE 0 END) AS null_inn,
    ROUND(SUM(CASE WHEN inn IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_inn_pct,
    SUM(CASE WHEN company_age IS NULL THEN 1 ELSE 0 END) AS null_company_age,
    ROUND(SUM(CASE WHEN company_age IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_company_age_pct,
    SUM(CASE WHEN num_employees IS NULL THEN 1 ELSE 0 END) AS null_num_employees,
    ROUND(SUM(CASE WHEN num_employees IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_num_employees_pct,
    SUM(CASE WHEN tax_debt IS NULL THEN 1 ELSE 0 END) AS null_tax_debt,
    ROUND(SUM(CASE WHEN tax_debt IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_tax_debt_pct,
    SUM(CASE WHEN paid_taxes IS NULL THEN 1 ELSE 0 END) AS null_paid_taxes,
    ROUND(SUM(CASE WHEN paid_taxes IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_paid_taxes_pct,
    SUM(CASE WHEN tax_debt_ratio IS NULL THEN 1 ELSE 0 END) AS null_tax_debt_ratio,
    ROUND(SUM(CASE WHEN tax_debt_ratio IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_tax_debt_ratio_pct,
    SUM(CASE WHEN has_state_support IS NULL THEN 1 ELSE 0 END) AS null_has_state_support,
    ROUND(SUM(CASE WHEN has_state_support IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_has_state_support_pct,
    SUM(CASE WHEN has_mass_founder IS NULL THEN 1 ELSE 0 END) AS null_has_mass_founder,
    ROUND(SUM(CASE WHEN has_mass_founder IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_has_mass_founder_pct,
    SUM(CASE WHEN total_assets IS NULL THEN 1 ELSE 0 END) AS null_total_assets,
    ROUND(SUM(CASE WHEN total_assets IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_total_assets_pct,
    SUM(CASE WHEN equity IS NULL THEN 1 ELSE 0 END) AS null_equity,
    ROUND(SUM(CASE WHEN equity IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_equity_pct,
    SUM(CASE WHEN current_assets IS NULL THEN 1 ELSE 0 END) AS null_current_assets,
    ROUND(SUM(CASE WHEN current_assets IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_current_assets_pct,
    SUM(CASE WHEN inventories IS NULL THEN 1 ELSE 0 END) AS null_inventories,
    ROUND(SUM(CASE WHEN inventories IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_inventories_pct,
    SUM(CASE WHEN current_liabilities IS NULL THEN 1 ELSE 0 END) AS null_current_liabilities,
    ROUND(SUM(CASE WHEN current_liabilities IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_current_liabilities_pct,
    SUM(CASE WHEN total_liabilities IS NULL THEN 1 ELSE 0 END) AS null_total_liabilities,
    ROUND(SUM(CASE WHEN total_liabilities IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_total_liabilities_pct,
    SUM(CASE WHEN revenue IS NULL THEN 1 ELSE 0 END) AS null_revenue,
    ROUND(SUM(CASE WHEN revenue IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_revenue_pct,
    SUM(CASE WHEN net_profit IS NULL THEN 1 ELSE 0 END) AS null_net_profit,
    ROUND(SUM(CASE WHEN net_profit IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_net_profit_pct,
    SUM(CASE WHEN revenue_prev IS NULL THEN 1 ELSE 0 END) AS null_revenue_prev,
    ROUND(SUM(CASE WHEN revenue_prev IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_revenue_prev_pct,
    SUM(CASE WHEN current_ratio IS NULL THEN 1 ELSE 0 END) AS null_current_ratio,
    ROUND(SUM(CASE WHEN current_ratio IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_current_ratio_pct,
    SUM(CASE WHEN quick_ratio IS NULL THEN 1 ELSE 0 END) AS null_quick_ratio,
    ROUND(SUM(CASE WHEN quick_ratio IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_quick_ratio_pct,
    SUM(CASE WHEN debt_to_equity IS NULL THEN 1 ELSE 0 END) AS null_debt_to_equity,
    ROUND(SUM(CASE WHEN debt_to_equity IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_debt_to_equity_pct,
    SUM(CASE WHEN debt_to_assets IS NULL THEN 1 ELSE 0 END) AS null_debt_to_assets,
    ROUND(SUM(CASE WHEN debt_to_assets IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_debt_to_assets_pct,
    SUM(CASE WHEN roa IS NULL THEN 1 ELSE 0 END) AS null_roa,
    ROUND(SUM(CASE WHEN roa IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_roa_pct,
    SUM(CASE WHEN roe IS NULL THEN 1 ELSE 0 END) AS null_roe,
    ROUND(SUM(CASE WHEN roe IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_roe_pct,
    SUM(CASE WHEN gross_margin IS NULL THEN 1 ELSE 0 END) AS null_gross_margin,
    ROUND(SUM(CASE WHEN gross_margin IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_gross_margin_pct,
    SUM(CASE WHEN net_margin IS NULL THEN 1 ELSE 0 END) AS null_net_margin,
    ROUND(SUM(CASE WHEN net_margin IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_net_margin_pct,
    SUM(CASE WHEN revenue_growth IS NULL THEN 1 ELSE 0 END) AS null_revenue_growth,
    ROUND(SUM(CASE WHEN revenue_growth IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_revenue_growth_pct,
    SUM(CASE WHEN revenue_cagr_3y IS NULL THEN 1 ELSE 0 END) AS null_revenue_cagr_3y,
    ROUND(SUM(CASE WHEN revenue_cagr_3y IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_revenue_cagr_3y_pct,
    SUM(CASE WHEN revenue_cagr_5y IS NULL THEN 1 ELSE 0 END) AS null_revenue_cagr_5y,
    ROUND(SUM(CASE WHEN revenue_cagr_5y IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_revenue_cagr_5y_pct,
    SUM(CASE WHEN roa_avg_3y IS NULL THEN 1 ELSE 0 END) AS null_roa_avg_3y,
    ROUND(SUM(CASE WHEN roa_avg_3y IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_roa_avg_3y_pct,
    SUM(CASE WHEN roa_avg_5y IS NULL THEN 1 ELSE 0 END) AS null_roa_avg_5y,
    ROUND(SUM(CASE WHEN roa_avg_5y IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_roa_avg_5y_pct,
    SUM(CASE WHEN roa_std_3y IS NULL THEN 1 ELSE 0 END) AS null_roa_std_3y,
    ROUND(SUM(CASE WHEN roa_std_3y IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_roa_std_3y_pct,
    SUM(CASE WHEN roa_std_5y IS NULL THEN 1 ELSE 0 END) AS null_roa_std_5y,
    ROUND(SUM(CASE WHEN roa_std_5y IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_roa_std_5y_pct,
    SUM(CASE WHEN debt_to_equity_avg_3y IS NULL THEN 1 ELSE 0 END) AS null_debt_to_equity_avg_3y,
    ROUND(SUM(CASE WHEN debt_to_equity_avg_3y IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_debt_to_equity_avg_3y_pct,
    SUM(CASE WHEN debt_to_equity_avg_5y IS NULL THEN 1 ELSE 0 END) AS null_debt_to_equity_avg_5y,
    ROUND(SUM(CASE WHEN debt_to_equity_avg_5y IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_debt_to_equity_avg_5y_pct,
    SUM(CASE WHEN debt_to_equity_trend_3y IS NULL THEN 1 ELSE 0 END) AS null_debt_to_equity_trend_3y,
    ROUND(SUM(CASE WHEN debt_to_equity_trend_3y IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_debt_to_equity_trend_3y_pct,
    SUM(CASE WHEN debt_to_equity_trend_5y IS NULL THEN 1 ELSE 0 END) AS null_debt_to_equity_trend_5y,
    ROUND(SUM(CASE WHEN debt_to_equity_trend_5y IS NULL THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 2) AS null_debt_to_equity_trend_5y_pct
FROM company_features;


SELECT count(*)
FROM company_features
WHERE (
    (CASE WHEN company_age IS NULL THEN 1 ELSE 0 END +
     CASE WHEN num_employees IS NULL THEN 1 ELSE 0 END +
     CASE WHEN revenue IS NULL THEN 1 ELSE 0 END +
     CASE WHEN total_assets IS NULL THEN 1 ELSE 0 END +
     CASE WHEN net_profit IS NULL THEN 1 ELSE 0 END +
     CASE WHEN revenue_cagr_3y IS NULL THEN 1 ELSE 0 END +
     CASE WHEN roa_avg_3y IS NULL THEN 1 ELSE 0 END)
    <= 1
);
