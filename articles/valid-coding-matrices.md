# Matrizen fuer valide Antworten und Ableitungen

Die Statusmatrizen pruefen, wie Quellstatus in Ableitungen weitergegeben
werden. Diese Seite ergaenzt sie um regulaere Antworten und bereits
kodierte Quellen. Die Regressionstests vergleichen jeweils `status`,
`value`, `code` und `score`. Auch eine regulaer beantwortete Aufgabe
ohne Punkte gehoert zu diesen Tests: Code `0` und Score `0` sind
gueltige Ergebnisse.

Die Sollwerte sind unabhaengig vom Autocoder festgelegt. Fuer das Update
von `@iqb/responses` 5.3.1 auf 5.5.0 werden dieselben Tests zuerst mit
dem alten Bundle und danach mit dem neuen Bundle ausgefuehrt. Ein
erfolgreiches Ergebnis mit der alten Version allein ersetzt die
fachliche Festlegung der Sollwerte nicht.

## Eingabe- und Ausgabematrix

Die fachlichen Faelle werden ueber vier Kombinationen geprueft:

| R-Funktion | Eingabe |
|----|----|
| [`code_responses()`](https://iqb-research.github.io/eatAutoCode/reference/code_responses.md) | R-Listen |
| [`code_responses()`](https://iqb-research.github.io/eatAutoCode/reference/code_responses.md) | JSON-Strings |
| [`code_responses_array()`](https://iqb-research.github.io/eatAutoCode/reference/code_responses_array.md) | R-Listen |
| [`code_responses_array()`](https://iqb-research.github.io/eatAutoCode/reference/code_responses_array.md) | JSON-Strings |

Der Array-Einstieg gibt Werte als Zeichenketten zurueck und verpackt
Mehrfachwerte standardmaessig als `[[[a;;;b]]]`. Die Tests
beruecksichtigen diesen dokumentierten Unterschied, pruefen aber in
allen Kombinationen dieselben Codes und Scores. Zusaetzlich werden
Antwort- und Unit-Bezeichner geprueft, damit bei der Verarbeitung
mehrerer Antworten keine Zuordnung verloren geht.

## Regulaere Antworten

Die 113 Testfaelle stehen in
`tests/testthat/test-valid_response_matrix.R`. Mit den vier
Eingabe-/API-Kombinationen ergibt das 452 Kodieraufrufe. Alle
Ausgangsantworten haben `status = "VALUE_CHANGED"`. Die Regeln
entscheiden zwischen einem passenden Code und einer regulaeren
Restkodierung. Erwartet wird jeweils `CODING_COMPLETE`, einschliesslich
der Antworten ohne Punkte.

### Numerische Regelmatrix

Die folgende Matrix verwendet die Antwortwerte `-2`, `-1`, `0`, `1` und
`2`. `ja` bedeutet Code `17`, Score `2.5`; `nein` bedeutet Code `0`,
Score `0`. Der Antwortwert bleibt erhalten. Dadurch koennen
Verwechslungen zwischen Antwortwert, Code und Score erkannt werden.

| Regel                | Parameter | -2   | -1   | 0    | 1    | 2    |
|----------------------|-----------|------|------|------|------|------|
| `NUMERIC_MATCH`      | `0`       | nein | nein | ja   | nein | nein |
| `NUMERIC_LESS_THAN`  | `0`       | ja   | ja   | nein | nein | nein |
| `NUMERIC_MAX`        | `0`       | ja   | ja   | ja   | nein | nein |
| `NUMERIC_MORE_THAN`  | `0`       | nein | nein | nein | ja   | ja   |
| `NUMERIC_MIN`        | `0`       | nein | nein | ja   | ja   | ja   |
| `NUMERIC_RANGE`      | `-1, 1`   | nein | nein | ja   | ja   | nein |
| `NUMERIC_FULL_RANGE` | `-1, 1`   | nein | ja   | ja   | ja   | nein |

Damit sind insbesondere die offenen und geschlossenen Intervallgrenzen
abgedeckt. Weitere Faelle pruefen negative Dezimalzahlen, numerische
Strings mit Punkt oder Komma sowie umgebende Leerzeichen.

### Weitere Regelgruppen

| Gruppe | Abgedeckte Unterschiede |
|----|----|
| Wahrheitswerte | `TRUE`/`FALSE`, `1`/`0` und entsprechende Strings; `IS_TRUE`/`IS_FALSE` |
| Textvergleich | Gross-/Kleinschreibung, Leerzeichen, Kombinationen der Verarbeitung und Unicode |
| Regulaere Ausdruecke | Unicode, Lookahead, Lookbehind, Rueckreferenzen, Unicode-/Hex-Escapes, passende und nicht passende Antworten |
| Mehrfachwerte | Positionen, `ANY`, `ANY_OPEN`, Summe, Laenge, Einzelelement und Sortierung nur fuer den Vergleich |
| Fragmente | Numerische und textuelle Teile einer fragmentierten Antwort |
| Regellogik | UND/ODER innerhalb eines Regelsatzes und zwischen Regelsaetzen |
| Codes und Scores | Kein, teilweiser und voller Credit; unterschiedliche Code-/Score-Werte; Vorrang der ersten passenden Regel |

## Valide Ableitungen

Die 188 Testfaelle stehen in
`tests/testthat/test-valid_derivation_matrix.R`. Mit den vier
Eingabe-/API-Kombinationen ergibt das 752 Kodieraufrufe. Fuer
mehrquellige Ableitungen werden unterschiedliche Quellprofile
vollstaendig gekreuzt. Alle Quellen enthalten valide Codes und Scores;
Werte, Codes und Scores sind absichtlich verschieden. Neben dem
abgeleiteten Wert wird auch dessen anschliessende Regelkodierung
geprueft.

| Methode | Zu pruefendes Ergebnis |
|----|----|
| `SUM_CODE` | Summe der Codes, einschliesslich Code `0` |
| `SUM_SCORE` | Summe der Scores, einschliesslich Score `0` und gebrochener Scores |
| `CONCAT_CODE` | Codes in der Reihenfolge von `deriveSources`; gesondert mit Sortierung |
| `UNIQUE_VALUES` | Eindeutigkeit der Werte; gleiche Codes oder Scores allein bedeuten keine gleichen Werte |
| `SOLVER` | Numerisches Ergebnis des Ausdrucks auf den Quellwerten |
| `COPY_VALUE` | Uebernahme einer einzelnen Quelle und erneute Regelkodierung des Zielwerts |
| `MANUAL` | Verarbeitung manueller Kodierungen und ihrer Quellabhaengigkeiten |

Weitere Faelle pruefen mehrstufige Ableitungen, Aliasse und eine von den
Abhaengigkeiten abweichende Eingabereihenfolge. Die erwarteten Zielcodes
und Scores sind eigenstaendige Sollwerte; ein pauschaler Restcode wuerde
einen falschen abgeleiteten Wert nicht zuverlaessig erkennen.

### Quellprofile und vollstaendige Wertmatrizen

Die fuenf Quellprofile unterscheiden Antwortwert, Code und Score.
Insbesondere haben `positive` und `same_value` denselben Antwortwert,
aber verschiedene Codes und Scores. Fuer `UNIQUE_VALUES` zaehlen sie
daher als gleiche Werte.

| profile    | value | code | score |
|:-----------|------:|-----:|------:|
| negative   |  -2.0 |   -3 |  1.50 |
| zero       |   0.0 |    0 |  0.00 |
| fraction   |   1.5 |    2 |  2.25 |
| positive   |   3.0 |    7 |  4.00 |
| same_value |   3.0 |   11 |  0.50 |

In jeder folgenden Matrix ist die Zeile die Quelle `a` und die Spalte
die Quelle `b`. Gezeigt wird der abgeleitete Wert. Die Zielvariable hat
eine exakt dazu passende Regel mit Code `41`, Score `2.5` und Endstatus
`CODING_COMPLETE`. Ein abweichender Wert erhaelt im Test einen
unterscheidbaren Restcode `99` mit Score `-1`. Die beiden Quellantworten
muessen ihre Werte, Codes und Scores behalten.

#### `SUM_CODE`

|            | negative | zero | fraction | positive | same_value |
|:-----------|---------:|-----:|---------:|---------:|-----------:|
| negative   |       -6 |   -3 |       -1 |        4 |          8 |
| zero       |       -3 |    0 |        2 |        7 |         11 |
| fraction   |       -1 |    2 |        4 |        9 |         13 |
| positive   |        4 |    7 |        9 |       14 |         18 |
| same_value |        8 |   11 |       13 |       18 |         22 |

#### `SUM_SCORE`

|            | negative | zero | fraction | positive | same_value |
|:-----------|---------:|-----:|---------:|---------:|-----------:|
| negative   |     3.00 | 1.50 |     3.75 |     5.50 |       2.00 |
| zero       |     1.50 | 0.00 |     2.25 |     4.00 |       0.50 |
| fraction   |     3.75 | 2.25 |     4.50 |     6.25 |       2.75 |
| positive   |     5.50 | 4.00 |     6.25 |     8.00 |       4.50 |
| same_value |     2.00 | 0.50 |     2.75 |     4.50 |       1.00 |

#### `CONCAT_CODE`

|            | negative | zero | fraction | positive | same_value |
|:-----------|:---------|:-----|:---------|:---------|:-----------|
| negative   | -3\_-3   | -3_0 | -3_2     | -3_7     | -3_11      |
| zero       | 0\_-3    | 0_0  | 0_2      | 0_7      | 0_11       |
| fraction   | 2\_-3    | 2_0  | 2_2      | 2_7      | 2_11       |
| positive   | 7\_-3    | 7_0  | 7_2      | 7_7      | 7_11       |
| same_value | 11\_-3   | 11_0 | 11_2     | 11_7     | 11_11      |

#### `UNIQUE_VALUES`

|            | negative | zero  | fraction | positive | same_value |
|:-----------|:---------|:------|:---------|:---------|:-----------|
| negative   | FALSE    | TRUE  | TRUE     | TRUE     | TRUE       |
| zero       | TRUE     | FALSE | TRUE     | TRUE     | TRUE       |
| fraction   | TRUE     | TRUE  | FALSE    | TRUE     | TRUE       |
| positive   | TRUE     | TRUE  | TRUE     | FALSE    | FALSE      |
| same_value | TRUE     | TRUE  | TRUE     | FALSE    | FALSE      |

#### `SOLVER`

Ausdruck: `2 * ${a} - ${b}`.

|            | negative | zero | fraction | positive | same_value |
|:-----------|---------:|-----:|---------:|---------:|-----------:|
| negative   |       -2 |   -4 |     -5.5 |       -7 |         -7 |
| zero       |        2 |    0 |     -1.5 |       -3 |         -3 |
| fraction   |        5 |    3 |      1.5 |        0 |          0 |
| positive   |        8 |    6 |      4.5 |        3 |          3 |
| same_value |        8 |    6 |      4.5 |        3 |          3 |

Fuer `CONCAT_CODE` wird die Eingabereihenfolge der Antworten absichtlich
umgekehrt; entscheidend bleibt `deriveSources = c("a", "b")`. Eine
weitere 5-x-5-Matrix prueft die Option `SORT`: Die Codes werden dabei
als Strings sortiert, sodass beispielsweise `11_2` entsteht.

`MANUAL` wird ebenfalls mit allen 25 Quellpaaren geprueft. Ohne
vorgegebene manuelle Kodierung wird die Ableitung abgeschlossen, liefert
aber keinen automatisch erzeugten Code oder Score. Zwei weitere Faelle
pruefen vorgegebene manuelle Codes einschliesslich Code `0`.

### Bekanntes Verhalten bei `COPY_VALUE`

Acht Faelle pruefen die regulaere Uebernahme skalarer und mehrwertiger
Antworten. Zwei weitere Faelle halten ein bereits in 5.3.1 vorhandenes
Verhalten fest: Der numerische Wert `0` und der boolesche Wert `FALSE`
werden von `COPY_VALUE` zu `null`. Die Strings `"0"` und `"false"`
bleiben dagegen erhalten.

Diese zwei Faelle sind ausdruecklich eine Beschreibung des bestehenden
Verhaltens und keine Aussage, dass die Umwandlung fachlich erwuenscht
ist. Sie machen sichtbar, ob sich dieses Verhalten beim Versionswechsel
aendert.

## Vergleich bei einem Update

1.  Tests und fachliche Sollwerte ergaenzen, waehrend das alte Bundle
    noch eingebunden ist.
2.  Die vollstaendige Testsuite mit dem alten Bundle ausfuehren und die
    Ergebnisse mit Paket- und Autocoder-Version festhalten.
3.  npm-Abhaengigkeiten aktualisieren, `npm run production` und
    `npm run updateVersion` ausfuehren.
4.  In einem frischen R-Prozess dieselben Tests unveraendert
    wiederholen.
5.  Jede Abweichung nach Eingabe, Methode und betroffenem Feld
    untersuchen. Sollwerte nur bei einer fachlich begruendeten
    Verhaltensaenderung anpassen.

Die neuen Partial-Credit-Optionen fuer angezeigte oder leere Quellen
werden gesondert getestet. Sie sind in den regulaeren Vergleichsmatrizen
ausgeschaltet. So bleiben die Ergebnisse fuer bisherige Coding-Schemes
direkt vergleichbar.

Die zugehoerigen Statuspruefungen sind in den Artikeln zu [allen
Ableitungsmethoden](https://iqb-research.github.io/eatAutoCode/articles/status-matrices-derivations.md)
und zu
[`SUM_SCORE`](https://iqb-research.github.io/eatAutoCode/articles/status-matrix-sum-score.md)
dokumentiert.
