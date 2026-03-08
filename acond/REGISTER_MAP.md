# Acond TČ 12 Monoblok EVI-M - Mapa Modbus registrů

## Řídící jednotka
- **PLC:** Tecomat Foxtrot (SW verze 61.8, FW 10.6)
- **IP:** `<ACOND_HOST>` (konfigurace v `scripts/acond_config.sh`)
- **Modbus TCP port:** 502, slave ID: 1
- **Web rozhraní:** HTTP port 80, login viz `scripts/acond_config.sh`

## Mapování Tecomat R-registrů na Modbus

```
Modbus holding register = R_addr / 2
Data type: 32-bit float IEEE 754, word swap (CDAB)
```

Platí pouze pro **sudé** R-adresy. Liché R-adresy (R815, R721) jsou nezarovnané
a nelze je přečíst jako standardní float32 přes dvě po sobě jdoucí 16-bit registry.

## DŮLEŽITÉ: Zápis registrů

**Modbus write NEFUNGUJE** - Tecomat přijímá write bez chyby, ale PLC program
hodnotu okamžitě přepíše. Zápis funguje výhradně přes **HTTP POST** na webové
rozhraní Tecomatu.

### Formát HTTP POST zápisu
```
POST /PAGE49.XML HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Cookie: SoftPLC=<session_id>

__R190_REAL_.1f=22.0
```

### Přihlášení (nutné pro POST)
```bash
curl -c /tmp/cookies.txt -d "USERNAME=<ACOND_USER>&PASSWORD=<ACOND_PASS>&SUBMIT=Login" \
  http://<ACOND_HOST>/syswww/login.xml
```

## Ověřené registry - Teploty (float32, swap: word) - ČTENÍ přes Modbus

| Modbus reg | R-registr | Popis | Ověřená hodnota |
|-----------|-----------|-------|-----------------|
| 95 | R190 | **Pokojová teplota setpoint (zapisovatelný!)** | 21.5°C |
| 3102 | R6204 | Teplota v místnosti aktuální | 22.3°C |
| 3104 | R6208 | Teplota v místnosti efektivní požadovaná (read-only) | 21.5°C |
| 3092 | R6184 | Teplota v místnosti 2. okruh | 32.2°C |
| 3090 | R6180 | Teplota vody v deskovém výměníku | 35.6°C |
| 3096 | R6192 | Teplota výstupu (kondenzátor) | 44.3°C |
| 3098 | R6196 | Teplota (neidentifikovaná) | 24.2°C |
| 3100 | R6200 | Venkovní teplota aktuální | 16.5°C |
| 36 | R72 | Venkovní teplota průměrná | 8.0°C |
| 3106 | R6212 | TUV aktuální | 41.3°C |
| 3108 | R6216 | TUV efektivní požadovaná (read-only) | 46.0°C |
| 385 | R770 | Konec ohřevu | 12.0°C |
| 3110 | R6220 | Teplota (neidentifikovaná) | 0.0°C |
| 904 | R1808 | Verze SW | 61.8 |

## Zapisovatelné registry - přes HTTP POST

| R-registr | Typ | POST body | Popis | Stránka |
|-----------|-----|-----------|-------|---------|
| R190 | REAL | `__R190_REAL_.1f=<val>` | Pokojová teplota setpoint 1. okruh | PAGE49.XML |
| R815 | REAL | `__R815_REAL_.1f=<val>` | TUV setpoint | PAGE49.XML |
| R770 | REAL | `__R770_REAL_.1f=<val>` | Konec ohřevu | PAGE49.XML |
| R805.4 | BOOL | `__R805.4_BOOL_i=0/1` | Časový plán TUV povolen | PAGE49.XML |
| R805.1 | BOOL | `__R805.1_BOOL_i=0/1` | Útlum ventilátoru | PAGE49.XML |
| R870.0-7 | BOOL | `__R870.x_BOOL_i=0/1` | Režim regulace/provozu | PAGE49.XML |

## Ověřené registry - Status (uint16)

| Modbus reg | R-registr | Byte | Popis |
|-----------|-----------|------|-------|
| 435 | R870/R871 | low | Regulace a režim (bitové pole) |
| 344 | R688/R689 | low | Provozní stav |
| 402 | R804/R805 | high | Příslušenství a funkce |

### R870 - Regulace a režim (low byte of reg 435)

| Bit | Hodnota | Popis |
|-----|---------|-------|
| 0 | 1 | AT - Regulace Acond Therm |
| 1 | 0 | EKV - Ekvitermní regulace |
| 2 | 0 | ST - Ruční zadání |
| 3 | 1 | AUT - Režim automatický |
| 4 | 0 | TČ - Režim pouze tepelné čerpadlo |
| 6 | 0 | BIV - Režim bivalence |
| 7 | 0 | VYP - Režim vypnuto |

### R688 - Provozní stav (low byte of reg 344)

| Bit | Popis |
|-----|-------|
| 0 | Ohřev TUV |
| 1 | Bivalence 1 |

### R805 - Příslušenství (HIGH byte of reg 402)

Tecomat čísluje bity od 1 (R805.1 = bit index 0 v high byte).

| R805.x | Bit index | Mask | Popis |
|--------|-----------|------|-------|
| R805.1 | 0 | 0x01 | Útlum ventilátoru |
| R805.2 | 1 | 0x02 | Bivalence aktivní |
| R805.3 | 2 | 0x04 | Antisepse povolena |
| R805.4 | 3 | 0x08 | **Časový plán TUV povolen** |

## Fyzické výstupy (Y-zone)

| Adresa | Popis | Stav |
|--------|-------|------|
| Y2.0 | (výstup 0) | 0 |
| Y2.1 | (výstup 1) | 0 |
| Y2.2 | (výstup 2) | 0 |
| Y2.4 | (výstup 4) | 0 |
| Y2.5 | (výstup 5) | 0 |
| Y2.6 | (výstup 6) | 0 |
| Y2.7 | (výstup 7) | 0 |
| Y3.0 | (výstup 8) | 0 |

## Časové plány TUV (R556-R664)

| R-registr | Typ | Popis |
|-----------|-----|-------|
| R556-R568 | TIME | Neděle okno 1+2 (OD/DO) |
| R572-R584 | TIME | Pondělí okno 1+2 |
| R588-R600 | TIME | Úterý okno 1+2 |
| R604-R616 | TIME | Středa okno 1+2 |
| R620-R632 | TIME | Čtvrtek okno 1+2 |
| R636-R648 | TIME | Pátek okno 1+2 |
| R652-R664 | TIME | Sobota okno 1+2 |

Aktuální plán: 00:00-04:00 a 13:00-15:00 každý den.

## Časové plány 2. okruh (R2196-R2304)

2\. okruh má časový plán ale **nemá osazené pokojové čidlo**.
Regulace jde pouze podle ekviterm křivky.

## Ekviterm křivka (float32, swap: word)

| Modbus reg | R-registr | Popis | Hodnota |
|-----------|-----------|-------|---------|
| 74 | R148 | Teplota topné vody při -20°C | 55.0°C |
| 76 | R152 | Teplota topné vody při -8°C | 45.0°C |
| 78 | R156 | Teplota topné vody při 5°C | 35.0°C |
| 80 | R160 | Teplota topné vody při 15°C | 25.0°C |
| 82 | R164 | Venkovní teplota bod 1 | -20.0°C |
| 84 | R168 | Venkovní teplota bod 2 | -8.0°C |
| 86 | R172 | Venkovní teplota bod 3 | 5.0°C |
| 88 | R176 | Venkovní teplota bod 4 | 15.0°C |
| 72 | R144 | Maximální teplota | 25.0°C |

## Příkazy pro mbpoll (pouze čtení)

```bash
# Čtení float hodnoty
mbpoll -a 1 -t 4:float -0 -r 3102 -c 1 -1 <ACOND_HOST>

# Čtení 16-bit hex (pro status registry)
mbpoll -a 1 -t 4:hex -0 -r 435 -c 1 -1 <ACOND_HOST>

# Čtení bloku teplot (R6180-R6240)
mbpoll -a 1 -t 4:float -0 -r 3090 -c 16 -1 <ACOND_HOST>
```

## Příkazy pro curl (zápis)

```bash
# Login
curl -c /tmp/c.txt -d "USERNAME=<ACOND_USER>&PASSWORD=<ACOND_PASS>&SUBMIT=Login" \
  http://<ACOND_HOST>/syswww/login.xml

# Nastavení pokojové teploty
curl -b /tmp/c.txt -d "__R190_REAL_.1f=22.0" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  http://<ACOND_HOST>/PAGE49.XML

# Vypnutí TUV plánu (jednorázový ohřev)
curl -b /tmp/c.txt -d "__R805.4_BOOL_i=0" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  http://<ACOND_HOST>/PAGE49.XML

# Zapnutí TUV plánu zpět
curl -b /tmp/c.txt -d "__R805.4_BOOL_i=1" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  http://<ACOND_HOST>/PAGE49.XML
```

## Poznámky k existujícím HA pluginům

Komunita HA (JH-Soft-Technology/acond-heat-card) používá registry 0-40 s int16
a scale 0.1. Toto mapování je pro **jiný typ řídící jednotky** (ne Tecomat Foxtrot).
Tento TČ 12 Monoblok EVI-M s Tecomat Foxtrot používá float32 na zcela jiných
adresách a zápis vyžaduje HTTP POST místo Modbus write.
