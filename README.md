# Descripción General

Este proyecto implementa un data warehouse con modelo estrella a partir de datos de ventas en bruto y realiza un análisis exploratorio de datos (EDA) usando SQL.

## Modelo de Datos

El diseño sigue un esquema estrella compuesto por:

### Tabla de Hechos

`fact_sales`

Granularidad: una fila por transacción de venta

### Métricas principales:

`sales_amount`

`quantity_sold`

`unit_price`

`unit_cost`

`discount`

## Tablas Dimensión

`dim_date` – atributos temporales (día, mes, nombre del mes, año)

`dim_product` – productos y categorías

`dim_region` – regiones geográficas

`dim_sales_rep` – representantes de ventas

`dim_customer_type` – tipos de clientes

`dim_payment_method` – métodos de pago

`dim_sales_channel` – canales de venta (online / offline)

## Pipeline de Datos (ETL)

Carga inicial de datos en `raw_sales`

Se poblo la DB usando varios INSERTS desde la table inicial `raw_sales`, esta es una conversion directa del CSV a sql.

usando joins connectamos las Llaves Foraneas, y insertamos las transacciones en `fact_sales`, tambien cree vistas e índices para optimizar análisis (aunque pocas).

## Resumen de KPIs

| Métrica                  | Valor                        |
| ------------------------ | ---------------------------- |
| Ingresos Totales         | $ 5019265.23                 |
| Total de Transacciones   | 1000                         |
| Valor Promedio por Venta | $ 5019.26523                 |
| Mejor Mes + Año          | Enero 2023 ($ 476092.36)     |
| Región con Más Ventas    | North (Norte - $ 1369612.51) |
| Canal Principal          | Offline (2560431.3)          |

## Análisis por Región

Región con mayor ingreso: **Region Norte**

Ingresos generados: **$1369612.51**

Región con menor desempeño: **Sur**

### Observaciones:

La region norte claramente domina, y es esencial para mantener los ingresos de la empresa. Indica importancia en expandir y mantener presecia en la zona.

La region sur sufre con mucho menor desempeño, que muestra una clara razon para implementar iniciativas de crecimiento.

## Canales de Venta

| Canal   | Ingresos   |
| ------- | ---------- |
| Online  | 2458833.93 |
| Offline | 2560431.3  |

### Conclusión clave:

Hay un mercado digital maduro con gran potencial. Con estrategias de marketing y preferencia digital se puede optimizar la cantidad de espacio y recusros necesarios para la venta.

## Análisis de Clientes

### Ventas por Tipo de Cliente
| Tipo de Cliente | Ingresos   | Venta Promedio |
| --------------- | ---------- | -------------- |
| Online          | 2458833.93 | 5066.55        |
| Offline         | 2560431.3  | 4972.73        |

### Insights:

- Clientes online tienen una venta promedio mas alta, lo cual sugiere que clientes online son de mas gasto en menos operaciones.

- El equilibrio muestra una fuente de ingresos diversificada y saludable con varias opciones de optimizacion de estrategia de ventas online como bundling y upselling.

## Métodos de Pago

- Método más utilizado: **Tarjeta De Credito**

- Ingresos generados: **$1757563.52**

### Observación:

El pago con tarjeta domina las ventas lo cual indica el deseo de los clientes por metodos de pago inmediatos y flexibles.

## Representantes de Ventas

Mejor representante: **David**

Ingresos generados: **$1141737.36**

Ticket promedio: **$5142.96**

## Análisis de Productos

### Productos con Mayor Ingreso

> Lamentablemente la CSV solo tiene el ID, no nombres

| Producto ID | Ingresos   | Venta Promedio |
| ----------- | ---------- | -------------- |
| 1099        | $101773.87 | 5654.10        |
| 1092        | $90615.62  | 4769.24        |
| 1033        | $89130.41  | 4951.69        |

### Producto Más Vendido por Cantidad
| Producto ID | Cantidad | Venta Total |
| ----------- | ---------- | -------------- |
| 1090 | 590 | 88043.25 |
| 1092 | 548 | 90615.62 |
| 1062 | 506 | 76696.76 |

### Categoría Principal

Categoría: __Muebles (Furniture)__

Ingresos: __$1566190.36__

## Análisis Temporal

### Tendencia Mensual de Ingresos

Mes con mayor ingreso: Mes 1 de 2023 (Enero 2023)

Mes con menor ingreso: Mes 1 2024 (Enero 2024)

Mayor crecimiento mensual (MoM): Octubre 2023 con 25.16%

### Resumen:

Los ingresus muestran estacionalidad, aunque tambien hay desaceleración interanual vista por el bajo ingreso en enero 2024 (puede ser causado por datos incompletos). El aggresivo MoM en Octubre indica algun repunte puntual posiblemente impulsado por campañas específicas o aumento temporal de la demanda

## Principales Conclusiones

- __El negocio presenta estabilidad general con crecimiento puntual, no sostenido.__
Aunque los ingresos totales superan los $5M, el análisis mensual muestra picos de crecimiento aislados (ej. octubre 2023 con +25.16% MoM) en lugar de una tendencia de crecimiento constante. Esto sugiere estacionalidad o impactos operativos específicos más que una expansión estructural del negocio.

- __El canal offline sigue siendo dominante, pero el online es competitivo.__
El canal Offline genera ligeramente más ingresos que Online, pero la diferencia es reducida. Esto indica una oportunidad clara de crecimiento digital: el canal online ya está maduro y podría superar al offline con mejoras en conversión, marketing o experiencia del cliente.

- __La región Norte es el principal motor de ingresos, generando dependencia geográfica.__
Con más de $1.36M en ingresos, la región Norte lidera claramente el desempeño. Sin embargo, esta concentración implica riesgo operativo: regiones como Sur muestran margen de mejora y deberían ser objetivo prioritario para estrategias comerciales o expansión.


