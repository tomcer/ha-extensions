# Acond TČ - Mapa Modbus registrů (ModbusTCP v2.34)

## Komunikační protokol
- **Protokol:** ModbusTCP, port 502
- **Kódování:** Big Endian
- **Režim:** TČ = Slave, uživatel = Master
- **Slave ID:** 1
- **Funkce:** 3, 4 (čtení), 6, 16 (zápis)
- **Aktivace:** Vyžaduje aktivaci servisním oddělením (601 373 073)

## Input registry - Read data (function code 4)

Adresa 0-based (30001 → addr 0). Teploty: Int x10 (scale 0.1 v HA).

| Addr | Modbus | Tag | Typ | Jednotky | Min | Max | Popis |
|------|--------|-----|-----|----------|-----|-----|-------|
| 0 | 30001 | T_set_indoor1 | Int x10 | °C | 100 | 300 | Žádaná teplota místnost okruh 1 |
| 1 | 30002 | T_act_indoor1 | Int x10 | °C | 0 | 500 | Aktuální teplota místnost okruh 1 |
| 2 | 30003 | T_set_indoor2 | Int x10 | °C | 100 | 300 | Žádaná teplota místnost okruh 2 |
| 3 | 30004 | T_act_indoor2 | Int x10 | °C | 0 | 500 | Aktuální teplota místnost okruh 2 |
| 4 | 30005 | T_set_TUV | Int x10 | °C | 100 | 460 | Žádaná teplota TUV |
| 5 | 30006 | T_act_TUV | Int x10 | °C | 0 | 900 | Aktuální teplota TUV |
| 6 | 30007 | TC_status | Word | - | - | - | Bitový stav TČ (viz níže) |
| 7 | 30008 | T_set_water_back | Int x10 | °C | 200 | 600 | Žádaná teplota zpátečky |
| 8 | 30009 | T_act_water_back | Int x10 | °C | -100 | 900 | Aktuální teplota zpátečky |
| 9 | 30010 | T_act_air | Int x10 | °C | -500 | 500 | Venkovní teplota |
| 10 | 30011 | T_act_solar | Int x10 | °C | -500 | 3000 | Teplota soláru |
| 11 | 30012 | T_act_pool | Int x10 | °C | 0 | 500 | Teplota bazénu |
| 12 | 30013 | T_set_pool | Int x10 | °C | - | - | Žádaná teplota bazénu |
| 13 | 30014 | rezim_pan | Int | - | - | - | Režim TČ (číselník) |
| 14 | 30015 | typ_reg_pan | Int | - | - | - | Typ regulace (číselník) |
| 15 | 30016 | T_solanka | Int x10 | °C | -300 | 500 | Teplota solanky |
| 16 | 30017 | HeartBeat | Int | - | 0 | 255 | Čítač komunikace |
| 17 | 30018 | T_act_water_outlet | Int x10 | °C | -100 | 900 | Teplota výstupní vody |
| 18 | 30019 | T_set_water_outlet | Int x10 | °C | 10 | 25 | Žádaná teplota výstupu (chlazení) |
| 19 | 30020 | Comp_rpm_max | Int | rpm | 0 | 7000 | Max otáčky kompresoru* |
| 20 | 30021 | err_number | Int | - | 0 | 62 | Číslo základní poruchy |
| 21 | 30022 | err_number_SECMono | Int | - | 0 | 42 | Číslo poruchy SECMono |
| 22 | 30023 | err_number_driver | Int | - | 0 | 39 | Číslo poruchy driveru |
| 23 | 30024 | comp_rpm_actual | Int | rpm | 0 | 7000 | Aktuální otáčky kompresoru* |

*Řada TČ PRO zobrazuje výkon (W) místo otáček (rpm).

## Holding registry - Write data (function code 6/16)

Adresa 0-based (40001 → addr 0). Teploty: Int x10 (v HA: value * 10).

| Addr | Modbus | Tag | Typ | Jednotky | Min | Max | Popis |
|------|--------|-----|-----|----------|-----|-----|-------|
| 0 | 40001 | T_set_indoor1 | Int x10 | °C | 100 | 300 | Žádaná teplota místnost okruh 1 |
| 1 | 40002 | T_act_indoor1 | Int x10 | °C | 0 | 500 | Aktuální teplota místnost okruh 1** |
| 2 | 40003 | T_set_indoor2 | Int x10 | °C | 100 | 300 | Žádaná teplota místnost okruh 2 |
| 3 | 40004 | T_act_indoor2 | Int x10 | °C | 0 | 500 | Aktuální teplota místnost okruh 2** |
| 4 | 40005 | T_set_TUV | Int x10 | °C | 100 | 460 | Žádaná teplota TUV |
| 5 | 40006 | TC_set | Word | - | 0 | 65535 | Nastavení TČ (režim, kvitace) |
| 6 | 40007 | TC_set_reg | Int | - | 0 | 2 | Typ regulace |
| 7 | 40008 | T_set_water_back | Int x10 | °C | 100 | 650 | Žádaná teplota zpátečky (režim ST) |
| 8 | 40009 | T_air | Int x10 | °C | -500 | 500 | Venkovní teplota** |
| 9 | 40010 | T_act_solar | Int x10 | °C | -500 | 3000 | Teplota soláru** |
| 10 | 40011 | T_act_pool | Int x10 | °C | 0 | 500 | Teplota bazénu** |
| 11 | 40012 | T_set_pool | Int x10 | °C | 100 | 500 | Žádaná teplota bazénu |
| 12 | 40013 | T_set_water_cool | Int x10 | °C | 150 | 300 | Žádaná teplota výstupu (chlazení) |
| 13 | 40014 | Comp_rpm_max | Int | rpm | 1800 | 6000 | Max otáčky kompresoru* |

**Hodnota mimo rozsah → TČ použije vlastní čidlo.
*Řada TČ PRO: Comp_capacity_max (W), rozsah 2000-20000.

## TC_status - Stav TČ (input reg 30007, bitové pole)

| Bit | Mask | Popis |
|-----|------|-------|
| 0 | 0x0001 | TČ zapnuto |
| 1 | 0x0002 | TČ chod (kompresor) |
| 2 | 0x0004 | TČ v poruše |
| 3 | 0x0008 | Probíhá ohřev TUV |
| 4 | 0x0010 | Oběh. čerpadlo topný okruh 1 |
| 5 | 0x0020 | Oběh. čerpadlo topný okruh 2 |
| 6 | 0x0040 | Oběh. čerpadlo soláru |
| 7 | 0x0080 | Oběh. čerpadlo bazénu |
| 8 | 0x0100 | Odmrazení |
| 9 | 0x0200 | Bivalence chod |
| 10 | 0x0400 | Letní provoz |
| 11 | 0x0800 | Oběh. čerpadlo solanka |
| 12 | 0x1000 | Chlazení chod |
| 13-15 | - | Rezerva |

## TC_set - Nastavení TČ (holding reg 40006, bitové pole)

| Bit | Mask | Popis |
|-----|------|-------|
| 0 | 0x0001 | Režim automatický |
| 1 | 0x0002 | Režim pouze TČ |
| 2 | 0x0004 | Režim bivalence |
| 3 | 0x0008 | Režim vypnuto |
| 4 | 0x0010 | Režim chlazení |
| 5 | 0x0020 | Kvitace poruchy |
| 6 | 0x0040 | Solár on |
| 7 | 0x0080 | Bazén on |
| 8 | 0x0100 | Přepnutí léto/zima |

## Číselník rezim_pan (input reg 30014)

| Hodnota | Popis |
|---------|-------|
| 0 | Automatický režim |
| 1 | Jen tepelné čerpadlo |
| 2 | Nepoužito |
| 3 | Jen bivalence |
| 4 | Vypnuto |
| 5 | Režim manual |
| 6 | Režim chlazení |

## Číselník typ_reg_pan (input reg 30015)

| Hodnota | Popis |
|---------|-------|
| 0 | AcondTherm |
| 1 | Ekviterm |
| 2 | Standard (ručně) |

## Data MIMO Modbus protokol (čtení přes HTTP web rozhraní)

Následující data Modbus protokol v2.34 neposkytuje:
- **HDO blokace** (X12.1) - fyzický vstup PLC
- **Alarm text** (R6513 string) - ale máme err_number kódy
- **TUV časový plán** (R805.4) - ovládání zapnutí/vypnutí plánu
- **Útlum ventilátoru** (R805.1)
- **Ekviterm křivka** (R148-R176)

## Příkazy pro testování

```bash
# Čtení input registrů (teploty, addr 0-5)
mbpoll -a 1 -t 3 -r 1 -c 6 -1 <ACOND_HOST>

# Čtení TC_status (addr 6)
mbpoll -a 1 -t 3:hex -r 7 -c 1 -1 <ACOND_HOST>

# Čtení režimu a regulace (addr 13-14)
mbpoll -a 1 -t 3 -r 14 -c 2 -1 <ACOND_HOST>

# Čtení chybových kódů (addr 20-22)
mbpoll -a 1 -t 3 -r 21 -c 3 -1 <ACOND_HOST>

# Zápis pokojové teploty 21.5°C (holding reg 40001, addr 0, hodnota 215)
mbpoll -a 1 -t 4 -r 1 -1 <ACOND_HOST> 215

# Zápis TUV 46°C (holding reg 40005, addr 4, hodnota 460)
mbpoll -a 1 -t 4 -r 5 -1 <ACOND_HOST> 460

# Kvitace alarmu (holding reg 40006, addr 5, bit 5 = 32)
mbpoll -a 1 -t 4 -r 6 -1 <ACOND_HOST> 32
```
