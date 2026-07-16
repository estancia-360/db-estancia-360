-- Fuente: documentos/Flujo_Caja_Estancia360_RECONSTRUIDO_sin_VALUE.xlsx (hoja "Planes y precios")
INSERT INTO subscription_plans (id_plan, name, capacity_min, capacity_max, price_monthly, price_annual, trial_days, is_active) VALUES
(1, 'Free',          0,    30,   0,   0,    0,  TRUE),
(2, 'Estancia',      31,   350,  100, 1000, 7,  TRUE),
(3, 'Hacienda',      351,  1500, 300, 3000, 14, TRUE),
(4, 'Ganadero Plus', 1501, NULL, 450, 4500, 21, TRUE);
