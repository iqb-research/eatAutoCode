# Statusmatrizen fuer alle Ableitungsmethoden

Diese Seite dokumentiert die erwartete Statusverrechnung fuer alle
Ableitungsmethoden im aktuellen `eatAutoCode`-Stand mit `@iqb/responses`
5.1.0.

Die Matrizen beschreiben das Endergebnis nach Ableitung und nach der
direkt anschliessenden Regelkodierung einer geschlossen kodierbaren
Zielvariable. In den zugehoerigen Regressionstests haben die
Zielvariablen deshalb eine `RESIDUAL_AUTO`-Regel. Erfolgreiche
Ableitungen, die intern zunaechst `VALUE_CHANGED` liefern, erscheinen im
Endstatus dadurch als `CODING_COMPLETE`.

Die Tests dazu stehen in
`tests/testthat/test-status_matrices_derivations.R`. Sie pruefen fuer
`MANUAL`, `CONCAT_CODE`, `SUM_CODE`, `SUM_SCORE`, `UNIQUE_VALUES` und
`SOLVER` jeweils alle `13 * 13 = 169` Kreuzungen der Quellstatus.
`COPY_VALUE` ist laut Coding-Scheme-Validierung eine
Einquellen-Ableitung; dafuer wird deshalb eine `13 * 1`-Matrix getestet
und dokumentiert.

## Abgedeckte Methoden

| method | documented_as | note |
|:---|:---|:---|
| MANUAL | 13 x 13 Kreuzmatrix | Mehrere Quellen sind fachlich als manuelle Vorcodierungen interpretierbar. |
| COPY_VALUE | 13 x 1 Einquellen-Matrix | Valide Schemes sollten genau eine Quelle verwenden. |
| CONCAT_CODE | 13 x 13 Kreuzmatrix | Aggregiert Codes der Quellen. |
| SUM_CODE | 13 x 13 Kreuzmatrix | Summiert Codes der Quellen. |
| SUM_SCORE | 13 x 13 Kreuzmatrix | Summiert Scores der Quellen. |
| UNIQUE_VALUES | 13 x 13 Kreuzmatrix | Prueft die Eindeutigkeit der Quellwerte. |
| SOLVER | 13 x 13 Kreuzmatrix | Wertet eine Solver-Expression auf Quellwerten aus. |

`BASE` und `BASE_NO_VALUE` sind keine Ableitungsmethoden mit
`deriveSources`-Statusverrechnung und werden deshalb hier nicht als
Matrix gefuehrt.

## Statusraum

| status              |
|:--------------------|
| VALUE_CHANGED       |
| CODING_COMPLETE     |
| INTENDED_INCOMPLETE |
| CODING_INCOMPLETE   |
| DERIVE_PENDING      |
| UNSET               |
| NOT_REACHED         |
| DISPLAYED           |
| PARTLY_DISPLAYED    |
| DERIVE_ERROR        |
| NO_CODING           |
| INVALID             |
| CODING_ERROR        |

Im Unterschied zur engeren `SUM_SCORE`-Seite ist `VALUE_CHANGED` hier
enthalten. Das ist fuer wertbasierte Ableitungsmethoden relevant
(`COPY_VALUE`, `UNIQUE_VALUES`, `SOLVER`) und macht diese Uebersicht zum
vollstaendigen 5.1.0-Statusraum.

## Gemeinsame Prioritaeten

Die folgenden Prioritaeten greifen vor der methodenspezifischen Logik.
Die erste passende Regel bestimmt den Status.

| order | condition                                | result       |
|------:|:-----------------------------------------|:-------------|
|     1 | Mindestens eine Quelle ist UNSET.        | UNSET        |
|     2 | Mindestens eine Quelle ist DERIVE_ERROR. | DERIVE_ERROR |
|     3 | Mindestens eine Quelle ist NO_CODING.    | DERIVE_ERROR |
|     4 | Mindestens eine Quelle ist CODING_ERROR. | CODING_ERROR |
|     5 | Mindestens eine Quelle ist INVALID.      | INVALID      |

## Gueltige Quellstatus nach Methode

Nach den gemeinsamen Prioritaeten zaehlt `@iqb/responses` 5.1.0 pro
Methode, welche Quellstatus fuer die Ableitung zulaessig sind.

|  | method | valid_source_statuses |
|:---|:---|:---|
| MANUAL | MANUAL | INVALID, VALUE_CHANGED, NO_CODING, CODING_ERROR, CODING_COMPLETE, INTENDED_INCOMPLETE |
| COPY_VALUE | COPY_VALUE | VALUE_CHANGED, NO_CODING, CODING_INCOMPLETE, CODING_ERROR, CODING_COMPLETE, INTENDED_INCOMPLETE |
| CONCAT_CODE | CONCAT_CODE | CODING_COMPLETE, INTENDED_INCOMPLETE |
| SUM_CODE | SUM_CODE | CODING_COMPLETE, INTENDED_INCOMPLETE |
| SUM_SCORE | SUM_SCORE | CODING_COMPLETE, INTENDED_INCOMPLETE |
| UNIQUE_VALUES | UNIQUE_VALUES | VALUE_CHANGED, NO_CODING, CODING_INCOMPLETE, CODING_ERROR, CODING_COMPLETE, INTENDED_INCOMPLETE |
| SOLVER | SOLVER | VALUE_CHANGED, NO_CODING, CODING_INCOMPLETE, CODING_ERROR, CODING_COMPLETE, INTENDED_INCOMPLETE |

Wichtig: Einige Status in dieser Liste werden bereits von den
gemeinsamen Prioritaeten abgefangen. Zum Beispiel fuehrt `NO_CODING`
immer zu `DERIVE_ERROR`, obwohl es fuer manche wertbasierte Methoden in
der internen Valid-State-Liste steht.

## Methodenspezifische Regeln

| methods | condition | result |
|:---|:---|:---|
| CONCAT_CODE, SUM_CODE, SUM_SCORE | Mindestens eine Quelle ist CODING_INCOMPLETE oder DERIVE_PENDING, und alle Quellen sind CODING_COMPLETE, INTENDED_INCOMPLETE, CODING_INCOMPLETE oder DERIVE_PENDING. | DERIVE_PENDING |
| Alle Methoden | Es gibt ungueltige Quellstatus und alle Quellen haben denselben Status. | Quellstatus wird uebernommen; VALUE_CHANGED wird im Testaufbau CODING_COMPLETE. |
| Alle Methoden | Es gibt ungueltige Quellstatus und alle Quellen sind NOT_REACHED, DISPLAYED oder PARTLY_DISPLAYED. | PARTLY_DISPLAYED |
| Alle Methoden | Es gibt ungueltige Quellstatus und keine der obigen Sonderregeln passt. | INVALID |
| MANUAL | Alle Quellen sind INTENDED_INCOMPLETE. | CODING_INCOMPLETE |
| MANUAL | Die Quellen sind nach den obigen Regeln fuer MANUAL gueltig. | CODING_COMPLETE |
| COPY_VALUE, CONCAT_CODE, SUM_CODE, SUM_SCORE, UNIQUE_VALUES, SOLVER | Die Ableitung liefert erfolgreich VALUE_CHANGED und wird danach kodiert. | CODING_COMPLETE |

## Matrixfunktionen

## Vollstaendige Matrizen

### `MANUAL`

| case | method | source_status_1     | source_status_2     | expected_status   |
|-----:|:-------|:--------------------|:--------------------|:------------------|
|    1 | MANUAL | VALUE_CHANGED       | VALUE_CHANGED       | CODING_COMPLETE   |
|    2 | MANUAL | VALUE_CHANGED       | CODING_COMPLETE     | CODING_COMPLETE   |
|    3 | MANUAL | VALUE_CHANGED       | INTENDED_INCOMPLETE | CODING_COMPLETE   |
|    4 | MANUAL | VALUE_CHANGED       | CODING_INCOMPLETE   | INVALID           |
|    5 | MANUAL | VALUE_CHANGED       | DERIVE_PENDING      | INVALID           |
|    6 | MANUAL | VALUE_CHANGED       | UNSET               | UNSET             |
|    7 | MANUAL | VALUE_CHANGED       | NOT_REACHED         | INVALID           |
|    8 | MANUAL | VALUE_CHANGED       | DISPLAYED           | INVALID           |
|    9 | MANUAL | VALUE_CHANGED       | PARTLY_DISPLAYED    | INVALID           |
|   10 | MANUAL | VALUE_CHANGED       | DERIVE_ERROR        | DERIVE_ERROR      |
|   11 | MANUAL | VALUE_CHANGED       | NO_CODING           | DERIVE_ERROR      |
|   12 | MANUAL | VALUE_CHANGED       | INVALID             | INVALID           |
|   13 | MANUAL | VALUE_CHANGED       | CODING_ERROR        | CODING_ERROR      |
|   14 | MANUAL | CODING_COMPLETE     | VALUE_CHANGED       | CODING_COMPLETE   |
|   15 | MANUAL | CODING_COMPLETE     | CODING_COMPLETE     | CODING_COMPLETE   |
|   16 | MANUAL | CODING_COMPLETE     | INTENDED_INCOMPLETE | CODING_COMPLETE   |
|   17 | MANUAL | CODING_COMPLETE     | CODING_INCOMPLETE   | INVALID           |
|   18 | MANUAL | CODING_COMPLETE     | DERIVE_PENDING      | INVALID           |
|   19 | MANUAL | CODING_COMPLETE     | UNSET               | UNSET             |
|   20 | MANUAL | CODING_COMPLETE     | NOT_REACHED         | INVALID           |
|   21 | MANUAL | CODING_COMPLETE     | DISPLAYED           | INVALID           |
|   22 | MANUAL | CODING_COMPLETE     | PARTLY_DISPLAYED    | INVALID           |
|   23 | MANUAL | CODING_COMPLETE     | DERIVE_ERROR        | DERIVE_ERROR      |
|   24 | MANUAL | CODING_COMPLETE     | NO_CODING           | DERIVE_ERROR      |
|   25 | MANUAL | CODING_COMPLETE     | INVALID             | INVALID           |
|   26 | MANUAL | CODING_COMPLETE     | CODING_ERROR        | CODING_ERROR      |
|   27 | MANUAL | INTENDED_INCOMPLETE | VALUE_CHANGED       | CODING_COMPLETE   |
|   28 | MANUAL | INTENDED_INCOMPLETE | CODING_COMPLETE     | CODING_COMPLETE   |
|   29 | MANUAL | INTENDED_INCOMPLETE | INTENDED_INCOMPLETE | CODING_INCOMPLETE |
|   30 | MANUAL | INTENDED_INCOMPLETE | CODING_INCOMPLETE   | INVALID           |
|   31 | MANUAL | INTENDED_INCOMPLETE | DERIVE_PENDING      | INVALID           |
|   32 | MANUAL | INTENDED_INCOMPLETE | UNSET               | UNSET             |
|   33 | MANUAL | INTENDED_INCOMPLETE | NOT_REACHED         | INVALID           |
|   34 | MANUAL | INTENDED_INCOMPLETE | DISPLAYED           | INVALID           |
|   35 | MANUAL | INTENDED_INCOMPLETE | PARTLY_DISPLAYED    | INVALID           |
|   36 | MANUAL | INTENDED_INCOMPLETE | DERIVE_ERROR        | DERIVE_ERROR      |
|   37 | MANUAL | INTENDED_INCOMPLETE | NO_CODING           | DERIVE_ERROR      |
|   38 | MANUAL | INTENDED_INCOMPLETE | INVALID             | INVALID           |
|   39 | MANUAL | INTENDED_INCOMPLETE | CODING_ERROR        | CODING_ERROR      |
|   40 | MANUAL | CODING_INCOMPLETE   | VALUE_CHANGED       | INVALID           |
|   41 | MANUAL | CODING_INCOMPLETE   | CODING_COMPLETE     | INVALID           |
|   42 | MANUAL | CODING_INCOMPLETE   | INTENDED_INCOMPLETE | INVALID           |
|   43 | MANUAL | CODING_INCOMPLETE   | CODING_INCOMPLETE   | CODING_INCOMPLETE |
|   44 | MANUAL | CODING_INCOMPLETE   | DERIVE_PENDING      | INVALID           |
|   45 | MANUAL | CODING_INCOMPLETE   | UNSET               | UNSET             |
|   46 | MANUAL | CODING_INCOMPLETE   | NOT_REACHED         | INVALID           |
|   47 | MANUAL | CODING_INCOMPLETE   | DISPLAYED           | INVALID           |
|   48 | MANUAL | CODING_INCOMPLETE   | PARTLY_DISPLAYED    | INVALID           |
|   49 | MANUAL | CODING_INCOMPLETE   | DERIVE_ERROR        | DERIVE_ERROR      |
|   50 | MANUAL | CODING_INCOMPLETE   | NO_CODING           | DERIVE_ERROR      |
|   51 | MANUAL | CODING_INCOMPLETE   | INVALID             | INVALID           |
|   52 | MANUAL | CODING_INCOMPLETE   | CODING_ERROR        | CODING_ERROR      |
|   53 | MANUAL | DERIVE_PENDING      | VALUE_CHANGED       | INVALID           |
|   54 | MANUAL | DERIVE_PENDING      | CODING_COMPLETE     | INVALID           |
|   55 | MANUAL | DERIVE_PENDING      | INTENDED_INCOMPLETE | INVALID           |
|   56 | MANUAL | DERIVE_PENDING      | CODING_INCOMPLETE   | INVALID           |
|   57 | MANUAL | DERIVE_PENDING      | DERIVE_PENDING      | DERIVE_PENDING    |
|   58 | MANUAL | DERIVE_PENDING      | UNSET               | UNSET             |
|   59 | MANUAL | DERIVE_PENDING      | NOT_REACHED         | INVALID           |
|   60 | MANUAL | DERIVE_PENDING      | DISPLAYED           | INVALID           |
|   61 | MANUAL | DERIVE_PENDING      | PARTLY_DISPLAYED    | INVALID           |
|   62 | MANUAL | DERIVE_PENDING      | DERIVE_ERROR        | DERIVE_ERROR      |
|   63 | MANUAL | DERIVE_PENDING      | NO_CODING           | DERIVE_ERROR      |
|   64 | MANUAL | DERIVE_PENDING      | INVALID             | INVALID           |
|   65 | MANUAL | DERIVE_PENDING      | CODING_ERROR        | CODING_ERROR      |
|   66 | MANUAL | UNSET               | VALUE_CHANGED       | UNSET             |
|   67 | MANUAL | UNSET               | CODING_COMPLETE     | UNSET             |
|   68 | MANUAL | UNSET               | INTENDED_INCOMPLETE | UNSET             |
|   69 | MANUAL | UNSET               | CODING_INCOMPLETE   | UNSET             |
|   70 | MANUAL | UNSET               | DERIVE_PENDING      | UNSET             |
|   71 | MANUAL | UNSET               | UNSET               | UNSET             |
|   72 | MANUAL | UNSET               | NOT_REACHED         | UNSET             |
|   73 | MANUAL | UNSET               | DISPLAYED           | UNSET             |
|   74 | MANUAL | UNSET               | PARTLY_DISPLAYED    | UNSET             |
|   75 | MANUAL | UNSET               | DERIVE_ERROR        | UNSET             |
|   76 | MANUAL | UNSET               | NO_CODING           | UNSET             |
|   77 | MANUAL | UNSET               | INVALID             | UNSET             |
|   78 | MANUAL | UNSET               | CODING_ERROR        | UNSET             |
|   79 | MANUAL | NOT_REACHED         | VALUE_CHANGED       | INVALID           |
|   80 | MANUAL | NOT_REACHED         | CODING_COMPLETE     | INVALID           |
|   81 | MANUAL | NOT_REACHED         | INTENDED_INCOMPLETE | INVALID           |
|   82 | MANUAL | NOT_REACHED         | CODING_INCOMPLETE   | INVALID           |
|   83 | MANUAL | NOT_REACHED         | DERIVE_PENDING      | INVALID           |
|   84 | MANUAL | NOT_REACHED         | UNSET               | UNSET             |
|   85 | MANUAL | NOT_REACHED         | NOT_REACHED         | NOT_REACHED       |
|   86 | MANUAL | NOT_REACHED         | DISPLAYED           | PARTLY_DISPLAYED  |
|   87 | MANUAL | NOT_REACHED         | PARTLY_DISPLAYED    | PARTLY_DISPLAYED  |
|   88 | MANUAL | NOT_REACHED         | DERIVE_ERROR        | DERIVE_ERROR      |
|   89 | MANUAL | NOT_REACHED         | NO_CODING           | DERIVE_ERROR      |
|   90 | MANUAL | NOT_REACHED         | INVALID             | INVALID           |
|   91 | MANUAL | NOT_REACHED         | CODING_ERROR        | CODING_ERROR      |
|   92 | MANUAL | DISPLAYED           | VALUE_CHANGED       | INVALID           |
|   93 | MANUAL | DISPLAYED           | CODING_COMPLETE     | INVALID           |
|   94 | MANUAL | DISPLAYED           | INTENDED_INCOMPLETE | INVALID           |
|   95 | MANUAL | DISPLAYED           | CODING_INCOMPLETE   | INVALID           |
|   96 | MANUAL | DISPLAYED           | DERIVE_PENDING      | INVALID           |
|   97 | MANUAL | DISPLAYED           | UNSET               | UNSET             |
|   98 | MANUAL | DISPLAYED           | NOT_REACHED         | PARTLY_DISPLAYED  |
|   99 | MANUAL | DISPLAYED           | DISPLAYED           | DISPLAYED         |
|  100 | MANUAL | DISPLAYED           | PARTLY_DISPLAYED    | PARTLY_DISPLAYED  |
|  101 | MANUAL | DISPLAYED           | DERIVE_ERROR        | DERIVE_ERROR      |
|  102 | MANUAL | DISPLAYED           | NO_CODING           | DERIVE_ERROR      |
|  103 | MANUAL | DISPLAYED           | INVALID             | INVALID           |
|  104 | MANUAL | DISPLAYED           | CODING_ERROR        | CODING_ERROR      |
|  105 | MANUAL | PARTLY_DISPLAYED    | VALUE_CHANGED       | INVALID           |
|  106 | MANUAL | PARTLY_DISPLAYED    | CODING_COMPLETE     | INVALID           |
|  107 | MANUAL | PARTLY_DISPLAYED    | INTENDED_INCOMPLETE | INVALID           |
|  108 | MANUAL | PARTLY_DISPLAYED    | CODING_INCOMPLETE   | INVALID           |
|  109 | MANUAL | PARTLY_DISPLAYED    | DERIVE_PENDING      | INVALID           |
|  110 | MANUAL | PARTLY_DISPLAYED    | UNSET               | UNSET             |
|  111 | MANUAL | PARTLY_DISPLAYED    | NOT_REACHED         | PARTLY_DISPLAYED  |
|  112 | MANUAL | PARTLY_DISPLAYED    | DISPLAYED           | PARTLY_DISPLAYED  |
|  113 | MANUAL | PARTLY_DISPLAYED    | PARTLY_DISPLAYED    | PARTLY_DISPLAYED  |
|  114 | MANUAL | PARTLY_DISPLAYED    | DERIVE_ERROR        | DERIVE_ERROR      |
|  115 | MANUAL | PARTLY_DISPLAYED    | NO_CODING           | DERIVE_ERROR      |
|  116 | MANUAL | PARTLY_DISPLAYED    | INVALID             | INVALID           |
|  117 | MANUAL | PARTLY_DISPLAYED    | CODING_ERROR        | CODING_ERROR      |
|  118 | MANUAL | DERIVE_ERROR        | VALUE_CHANGED       | DERIVE_ERROR      |
|  119 | MANUAL | DERIVE_ERROR        | CODING_COMPLETE     | DERIVE_ERROR      |
|  120 | MANUAL | DERIVE_ERROR        | INTENDED_INCOMPLETE | DERIVE_ERROR      |
|  121 | MANUAL | DERIVE_ERROR        | CODING_INCOMPLETE   | DERIVE_ERROR      |
|  122 | MANUAL | DERIVE_ERROR        | DERIVE_PENDING      | DERIVE_ERROR      |
|  123 | MANUAL | DERIVE_ERROR        | UNSET               | UNSET             |
|  124 | MANUAL | DERIVE_ERROR        | NOT_REACHED         | DERIVE_ERROR      |
|  125 | MANUAL | DERIVE_ERROR        | DISPLAYED           | DERIVE_ERROR      |
|  126 | MANUAL | DERIVE_ERROR        | PARTLY_DISPLAYED    | DERIVE_ERROR      |
|  127 | MANUAL | DERIVE_ERROR        | DERIVE_ERROR        | DERIVE_ERROR      |
|  128 | MANUAL | DERIVE_ERROR        | NO_CODING           | DERIVE_ERROR      |
|  129 | MANUAL | DERIVE_ERROR        | INVALID             | DERIVE_ERROR      |
|  130 | MANUAL | DERIVE_ERROR        | CODING_ERROR        | DERIVE_ERROR      |
|  131 | MANUAL | NO_CODING           | VALUE_CHANGED       | DERIVE_ERROR      |
|  132 | MANUAL | NO_CODING           | CODING_COMPLETE     | DERIVE_ERROR      |
|  133 | MANUAL | NO_CODING           | INTENDED_INCOMPLETE | DERIVE_ERROR      |
|  134 | MANUAL | NO_CODING           | CODING_INCOMPLETE   | DERIVE_ERROR      |
|  135 | MANUAL | NO_CODING           | DERIVE_PENDING      | DERIVE_ERROR      |
|  136 | MANUAL | NO_CODING           | UNSET               | UNSET             |
|  137 | MANUAL | NO_CODING           | NOT_REACHED         | DERIVE_ERROR      |
|  138 | MANUAL | NO_CODING           | DISPLAYED           | DERIVE_ERROR      |
|  139 | MANUAL | NO_CODING           | PARTLY_DISPLAYED    | DERIVE_ERROR      |
|  140 | MANUAL | NO_CODING           | DERIVE_ERROR        | DERIVE_ERROR      |
|  141 | MANUAL | NO_CODING           | NO_CODING           | DERIVE_ERROR      |
|  142 | MANUAL | NO_CODING           | INVALID             | DERIVE_ERROR      |
|  143 | MANUAL | NO_CODING           | CODING_ERROR        | DERIVE_ERROR      |
|  144 | MANUAL | INVALID             | VALUE_CHANGED       | INVALID           |
|  145 | MANUAL | INVALID             | CODING_COMPLETE     | INVALID           |
|  146 | MANUAL | INVALID             | INTENDED_INCOMPLETE | INVALID           |
|  147 | MANUAL | INVALID             | CODING_INCOMPLETE   | INVALID           |
|  148 | MANUAL | INVALID             | DERIVE_PENDING      | INVALID           |
|  149 | MANUAL | INVALID             | UNSET               | UNSET             |
|  150 | MANUAL | INVALID             | NOT_REACHED         | INVALID           |
|  151 | MANUAL | INVALID             | DISPLAYED           | INVALID           |
|  152 | MANUAL | INVALID             | PARTLY_DISPLAYED    | INVALID           |
|  153 | MANUAL | INVALID             | DERIVE_ERROR        | DERIVE_ERROR      |
|  154 | MANUAL | INVALID             | NO_CODING           | DERIVE_ERROR      |
|  155 | MANUAL | INVALID             | INVALID             | INVALID           |
|  156 | MANUAL | INVALID             | CODING_ERROR        | CODING_ERROR      |
|  157 | MANUAL | CODING_ERROR        | VALUE_CHANGED       | CODING_ERROR      |
|  158 | MANUAL | CODING_ERROR        | CODING_COMPLETE     | CODING_ERROR      |
|  159 | MANUAL | CODING_ERROR        | INTENDED_INCOMPLETE | CODING_ERROR      |
|  160 | MANUAL | CODING_ERROR        | CODING_INCOMPLETE   | CODING_ERROR      |
|  161 | MANUAL | CODING_ERROR        | DERIVE_PENDING      | CODING_ERROR      |
|  162 | MANUAL | CODING_ERROR        | UNSET               | UNSET             |
|  163 | MANUAL | CODING_ERROR        | NOT_REACHED         | CODING_ERROR      |
|  164 | MANUAL | CODING_ERROR        | DISPLAYED           | CODING_ERROR      |
|  165 | MANUAL | CODING_ERROR        | PARTLY_DISPLAYED    | CODING_ERROR      |
|  166 | MANUAL | CODING_ERROR        | DERIVE_ERROR        | DERIVE_ERROR      |
|  167 | MANUAL | CODING_ERROR        | NO_CODING           | DERIVE_ERROR      |
|  168 | MANUAL | CODING_ERROR        | INVALID             | CODING_ERROR      |
|  169 | MANUAL | CODING_ERROR        | CODING_ERROR        | CODING_ERROR      |

### `CONCAT_CODE`

| case | method      | source_status_1     | source_status_2     | expected_status  |
|-----:|:------------|:--------------------|:--------------------|:-----------------|
|    1 | CONCAT_CODE | VALUE_CHANGED       | VALUE_CHANGED       | CODING_COMPLETE  |
|    2 | CONCAT_CODE | VALUE_CHANGED       | CODING_COMPLETE     | INVALID          |
|    3 | CONCAT_CODE | VALUE_CHANGED       | INTENDED_INCOMPLETE | INVALID          |
|    4 | CONCAT_CODE | VALUE_CHANGED       | CODING_INCOMPLETE   | INVALID          |
|    5 | CONCAT_CODE | VALUE_CHANGED       | DERIVE_PENDING      | INVALID          |
|    6 | CONCAT_CODE | VALUE_CHANGED       | UNSET               | UNSET            |
|    7 | CONCAT_CODE | VALUE_CHANGED       | NOT_REACHED         | INVALID          |
|    8 | CONCAT_CODE | VALUE_CHANGED       | DISPLAYED           | INVALID          |
|    9 | CONCAT_CODE | VALUE_CHANGED       | PARTLY_DISPLAYED    | INVALID          |
|   10 | CONCAT_CODE | VALUE_CHANGED       | DERIVE_ERROR        | DERIVE_ERROR     |
|   11 | CONCAT_CODE | VALUE_CHANGED       | NO_CODING           | DERIVE_ERROR     |
|   12 | CONCAT_CODE | VALUE_CHANGED       | INVALID             | INVALID          |
|   13 | CONCAT_CODE | VALUE_CHANGED       | CODING_ERROR        | CODING_ERROR     |
|   14 | CONCAT_CODE | CODING_COMPLETE     | VALUE_CHANGED       | INVALID          |
|   15 | CONCAT_CODE | CODING_COMPLETE     | CODING_COMPLETE     | CODING_COMPLETE  |
|   16 | CONCAT_CODE | CODING_COMPLETE     | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   17 | CONCAT_CODE | CODING_COMPLETE     | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   18 | CONCAT_CODE | CODING_COMPLETE     | DERIVE_PENDING      | DERIVE_PENDING   |
|   19 | CONCAT_CODE | CODING_COMPLETE     | UNSET               | UNSET            |
|   20 | CONCAT_CODE | CODING_COMPLETE     | NOT_REACHED         | INVALID          |
|   21 | CONCAT_CODE | CODING_COMPLETE     | DISPLAYED           | INVALID          |
|   22 | CONCAT_CODE | CODING_COMPLETE     | PARTLY_DISPLAYED    | INVALID          |
|   23 | CONCAT_CODE | CODING_COMPLETE     | DERIVE_ERROR        | DERIVE_ERROR     |
|   24 | CONCAT_CODE | CODING_COMPLETE     | NO_CODING           | DERIVE_ERROR     |
|   25 | CONCAT_CODE | CODING_COMPLETE     | INVALID             | INVALID          |
|   26 | CONCAT_CODE | CODING_COMPLETE     | CODING_ERROR        | CODING_ERROR     |
|   27 | CONCAT_CODE | INTENDED_INCOMPLETE | VALUE_CHANGED       | INVALID          |
|   28 | CONCAT_CODE | INTENDED_INCOMPLETE | CODING_COMPLETE     | CODING_COMPLETE  |
|   29 | CONCAT_CODE | INTENDED_INCOMPLETE | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   30 | CONCAT_CODE | INTENDED_INCOMPLETE | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   31 | CONCAT_CODE | INTENDED_INCOMPLETE | DERIVE_PENDING      | DERIVE_PENDING   |
|   32 | CONCAT_CODE | INTENDED_INCOMPLETE | UNSET               | UNSET            |
|   33 | CONCAT_CODE | INTENDED_INCOMPLETE | NOT_REACHED         | INVALID          |
|   34 | CONCAT_CODE | INTENDED_INCOMPLETE | DISPLAYED           | INVALID          |
|   35 | CONCAT_CODE | INTENDED_INCOMPLETE | PARTLY_DISPLAYED    | INVALID          |
|   36 | CONCAT_CODE | INTENDED_INCOMPLETE | DERIVE_ERROR        | DERIVE_ERROR     |
|   37 | CONCAT_CODE | INTENDED_INCOMPLETE | NO_CODING           | DERIVE_ERROR     |
|   38 | CONCAT_CODE | INTENDED_INCOMPLETE | INVALID             | INVALID          |
|   39 | CONCAT_CODE | INTENDED_INCOMPLETE | CODING_ERROR        | CODING_ERROR     |
|   40 | CONCAT_CODE | CODING_INCOMPLETE   | VALUE_CHANGED       | INVALID          |
|   41 | CONCAT_CODE | CODING_INCOMPLETE   | CODING_COMPLETE     | DERIVE_PENDING   |
|   42 | CONCAT_CODE | CODING_INCOMPLETE   | INTENDED_INCOMPLETE | DERIVE_PENDING   |
|   43 | CONCAT_CODE | CODING_INCOMPLETE   | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   44 | CONCAT_CODE | CODING_INCOMPLETE   | DERIVE_PENDING      | DERIVE_PENDING   |
|   45 | CONCAT_CODE | CODING_INCOMPLETE   | UNSET               | UNSET            |
|   46 | CONCAT_CODE | CODING_INCOMPLETE   | NOT_REACHED         | INVALID          |
|   47 | CONCAT_CODE | CODING_INCOMPLETE   | DISPLAYED           | INVALID          |
|   48 | CONCAT_CODE | CODING_INCOMPLETE   | PARTLY_DISPLAYED    | INVALID          |
|   49 | CONCAT_CODE | CODING_INCOMPLETE   | DERIVE_ERROR        | DERIVE_ERROR     |
|   50 | CONCAT_CODE | CODING_INCOMPLETE   | NO_CODING           | DERIVE_ERROR     |
|   51 | CONCAT_CODE | CODING_INCOMPLETE   | INVALID             | INVALID          |
|   52 | CONCAT_CODE | CODING_INCOMPLETE   | CODING_ERROR        | CODING_ERROR     |
|   53 | CONCAT_CODE | DERIVE_PENDING      | VALUE_CHANGED       | INVALID          |
|   54 | CONCAT_CODE | DERIVE_PENDING      | CODING_COMPLETE     | DERIVE_PENDING   |
|   55 | CONCAT_CODE | DERIVE_PENDING      | INTENDED_INCOMPLETE | DERIVE_PENDING   |
|   56 | CONCAT_CODE | DERIVE_PENDING      | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   57 | CONCAT_CODE | DERIVE_PENDING      | DERIVE_PENDING      | DERIVE_PENDING   |
|   58 | CONCAT_CODE | DERIVE_PENDING      | UNSET               | UNSET            |
|   59 | CONCAT_CODE | DERIVE_PENDING      | NOT_REACHED         | INVALID          |
|   60 | CONCAT_CODE | DERIVE_PENDING      | DISPLAYED           | INVALID          |
|   61 | CONCAT_CODE | DERIVE_PENDING      | PARTLY_DISPLAYED    | INVALID          |
|   62 | CONCAT_CODE | DERIVE_PENDING      | DERIVE_ERROR        | DERIVE_ERROR     |
|   63 | CONCAT_CODE | DERIVE_PENDING      | NO_CODING           | DERIVE_ERROR     |
|   64 | CONCAT_CODE | DERIVE_PENDING      | INVALID             | INVALID          |
|   65 | CONCAT_CODE | DERIVE_PENDING      | CODING_ERROR        | CODING_ERROR     |
|   66 | CONCAT_CODE | UNSET               | VALUE_CHANGED       | UNSET            |
|   67 | CONCAT_CODE | UNSET               | CODING_COMPLETE     | UNSET            |
|   68 | CONCAT_CODE | UNSET               | INTENDED_INCOMPLETE | UNSET            |
|   69 | CONCAT_CODE | UNSET               | CODING_INCOMPLETE   | UNSET            |
|   70 | CONCAT_CODE | UNSET               | DERIVE_PENDING      | UNSET            |
|   71 | CONCAT_CODE | UNSET               | UNSET               | UNSET            |
|   72 | CONCAT_CODE | UNSET               | NOT_REACHED         | UNSET            |
|   73 | CONCAT_CODE | UNSET               | DISPLAYED           | UNSET            |
|   74 | CONCAT_CODE | UNSET               | PARTLY_DISPLAYED    | UNSET            |
|   75 | CONCAT_CODE | UNSET               | DERIVE_ERROR        | UNSET            |
|   76 | CONCAT_CODE | UNSET               | NO_CODING           | UNSET            |
|   77 | CONCAT_CODE | UNSET               | INVALID             | UNSET            |
|   78 | CONCAT_CODE | UNSET               | CODING_ERROR        | UNSET            |
|   79 | CONCAT_CODE | NOT_REACHED         | VALUE_CHANGED       | INVALID          |
|   80 | CONCAT_CODE | NOT_REACHED         | CODING_COMPLETE     | INVALID          |
|   81 | CONCAT_CODE | NOT_REACHED         | INTENDED_INCOMPLETE | INVALID          |
|   82 | CONCAT_CODE | NOT_REACHED         | CODING_INCOMPLETE   | INVALID          |
|   83 | CONCAT_CODE | NOT_REACHED         | DERIVE_PENDING      | INVALID          |
|   84 | CONCAT_CODE | NOT_REACHED         | UNSET               | UNSET            |
|   85 | CONCAT_CODE | NOT_REACHED         | NOT_REACHED         | NOT_REACHED      |
|   86 | CONCAT_CODE | NOT_REACHED         | DISPLAYED           | PARTLY_DISPLAYED |
|   87 | CONCAT_CODE | NOT_REACHED         | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|   88 | CONCAT_CODE | NOT_REACHED         | DERIVE_ERROR        | DERIVE_ERROR     |
|   89 | CONCAT_CODE | NOT_REACHED         | NO_CODING           | DERIVE_ERROR     |
|   90 | CONCAT_CODE | NOT_REACHED         | INVALID             | INVALID          |
|   91 | CONCAT_CODE | NOT_REACHED         | CODING_ERROR        | CODING_ERROR     |
|   92 | CONCAT_CODE | DISPLAYED           | VALUE_CHANGED       | INVALID          |
|   93 | CONCAT_CODE | DISPLAYED           | CODING_COMPLETE     | INVALID          |
|   94 | CONCAT_CODE | DISPLAYED           | INTENDED_INCOMPLETE | INVALID          |
|   95 | CONCAT_CODE | DISPLAYED           | CODING_INCOMPLETE   | INVALID          |
|   96 | CONCAT_CODE | DISPLAYED           | DERIVE_PENDING      | INVALID          |
|   97 | CONCAT_CODE | DISPLAYED           | UNSET               | UNSET            |
|   98 | CONCAT_CODE | DISPLAYED           | NOT_REACHED         | PARTLY_DISPLAYED |
|   99 | CONCAT_CODE | DISPLAYED           | DISPLAYED           | DISPLAYED        |
|  100 | CONCAT_CODE | DISPLAYED           | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|  101 | CONCAT_CODE | DISPLAYED           | DERIVE_ERROR        | DERIVE_ERROR     |
|  102 | CONCAT_CODE | DISPLAYED           | NO_CODING           | DERIVE_ERROR     |
|  103 | CONCAT_CODE | DISPLAYED           | INVALID             | INVALID          |
|  104 | CONCAT_CODE | DISPLAYED           | CODING_ERROR        | CODING_ERROR     |
|  105 | CONCAT_CODE | PARTLY_DISPLAYED    | VALUE_CHANGED       | INVALID          |
|  106 | CONCAT_CODE | PARTLY_DISPLAYED    | CODING_COMPLETE     | INVALID          |
|  107 | CONCAT_CODE | PARTLY_DISPLAYED    | INTENDED_INCOMPLETE | INVALID          |
|  108 | CONCAT_CODE | PARTLY_DISPLAYED    | CODING_INCOMPLETE   | INVALID          |
|  109 | CONCAT_CODE | PARTLY_DISPLAYED    | DERIVE_PENDING      | INVALID          |
|  110 | CONCAT_CODE | PARTLY_DISPLAYED    | UNSET               | UNSET            |
|  111 | CONCAT_CODE | PARTLY_DISPLAYED    | NOT_REACHED         | PARTLY_DISPLAYED |
|  112 | CONCAT_CODE | PARTLY_DISPLAYED    | DISPLAYED           | PARTLY_DISPLAYED |
|  113 | CONCAT_CODE | PARTLY_DISPLAYED    | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|  114 | CONCAT_CODE | PARTLY_DISPLAYED    | DERIVE_ERROR        | DERIVE_ERROR     |
|  115 | CONCAT_CODE | PARTLY_DISPLAYED    | NO_CODING           | DERIVE_ERROR     |
|  116 | CONCAT_CODE | PARTLY_DISPLAYED    | INVALID             | INVALID          |
|  117 | CONCAT_CODE | PARTLY_DISPLAYED    | CODING_ERROR        | CODING_ERROR     |
|  118 | CONCAT_CODE | DERIVE_ERROR        | VALUE_CHANGED       | DERIVE_ERROR     |
|  119 | CONCAT_CODE | DERIVE_ERROR        | CODING_COMPLETE     | DERIVE_ERROR     |
|  120 | CONCAT_CODE | DERIVE_ERROR        | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|  121 | CONCAT_CODE | DERIVE_ERROR        | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  122 | CONCAT_CODE | DERIVE_ERROR        | DERIVE_PENDING      | DERIVE_ERROR     |
|  123 | CONCAT_CODE | DERIVE_ERROR        | UNSET               | UNSET            |
|  124 | CONCAT_CODE | DERIVE_ERROR        | NOT_REACHED         | DERIVE_ERROR     |
|  125 | CONCAT_CODE | DERIVE_ERROR        | DISPLAYED           | DERIVE_ERROR     |
|  126 | CONCAT_CODE | DERIVE_ERROR        | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  127 | CONCAT_CODE | DERIVE_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  128 | CONCAT_CODE | DERIVE_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  129 | CONCAT_CODE | DERIVE_ERROR        | INVALID             | DERIVE_ERROR     |
|  130 | CONCAT_CODE | DERIVE_ERROR        | CODING_ERROR        | DERIVE_ERROR     |
|  131 | CONCAT_CODE | NO_CODING           | VALUE_CHANGED       | DERIVE_ERROR     |
|  132 | CONCAT_CODE | NO_CODING           | CODING_COMPLETE     | DERIVE_ERROR     |
|  133 | CONCAT_CODE | NO_CODING           | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|  134 | CONCAT_CODE | NO_CODING           | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  135 | CONCAT_CODE | NO_CODING           | DERIVE_PENDING      | DERIVE_ERROR     |
|  136 | CONCAT_CODE | NO_CODING           | UNSET               | UNSET            |
|  137 | CONCAT_CODE | NO_CODING           | NOT_REACHED         | DERIVE_ERROR     |
|  138 | CONCAT_CODE | NO_CODING           | DISPLAYED           | DERIVE_ERROR     |
|  139 | CONCAT_CODE | NO_CODING           | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  140 | CONCAT_CODE | NO_CODING           | DERIVE_ERROR        | DERIVE_ERROR     |
|  141 | CONCAT_CODE | NO_CODING           | NO_CODING           | DERIVE_ERROR     |
|  142 | CONCAT_CODE | NO_CODING           | INVALID             | DERIVE_ERROR     |
|  143 | CONCAT_CODE | NO_CODING           | CODING_ERROR        | DERIVE_ERROR     |
|  144 | CONCAT_CODE | INVALID             | VALUE_CHANGED       | INVALID          |
|  145 | CONCAT_CODE | INVALID             | CODING_COMPLETE     | INVALID          |
|  146 | CONCAT_CODE | INVALID             | INTENDED_INCOMPLETE | INVALID          |
|  147 | CONCAT_CODE | INVALID             | CODING_INCOMPLETE   | INVALID          |
|  148 | CONCAT_CODE | INVALID             | DERIVE_PENDING      | INVALID          |
|  149 | CONCAT_CODE | INVALID             | UNSET               | UNSET            |
|  150 | CONCAT_CODE | INVALID             | NOT_REACHED         | INVALID          |
|  151 | CONCAT_CODE | INVALID             | DISPLAYED           | INVALID          |
|  152 | CONCAT_CODE | INVALID             | PARTLY_DISPLAYED    | INVALID          |
|  153 | CONCAT_CODE | INVALID             | DERIVE_ERROR        | DERIVE_ERROR     |
|  154 | CONCAT_CODE | INVALID             | NO_CODING           | DERIVE_ERROR     |
|  155 | CONCAT_CODE | INVALID             | INVALID             | INVALID          |
|  156 | CONCAT_CODE | INVALID             | CODING_ERROR        | CODING_ERROR     |
|  157 | CONCAT_CODE | CODING_ERROR        | VALUE_CHANGED       | CODING_ERROR     |
|  158 | CONCAT_CODE | CODING_ERROR        | CODING_COMPLETE     | CODING_ERROR     |
|  159 | CONCAT_CODE | CODING_ERROR        | INTENDED_INCOMPLETE | CODING_ERROR     |
|  160 | CONCAT_CODE | CODING_ERROR        | CODING_INCOMPLETE   | CODING_ERROR     |
|  161 | CONCAT_CODE | CODING_ERROR        | DERIVE_PENDING      | CODING_ERROR     |
|  162 | CONCAT_CODE | CODING_ERROR        | UNSET               | UNSET            |
|  163 | CONCAT_CODE | CODING_ERROR        | NOT_REACHED         | CODING_ERROR     |
|  164 | CONCAT_CODE | CODING_ERROR        | DISPLAYED           | CODING_ERROR     |
|  165 | CONCAT_CODE | CODING_ERROR        | PARTLY_DISPLAYED    | CODING_ERROR     |
|  166 | CONCAT_CODE | CODING_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  167 | CONCAT_CODE | CODING_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  168 | CONCAT_CODE | CODING_ERROR        | INVALID             | CODING_ERROR     |
|  169 | CONCAT_CODE | CODING_ERROR        | CODING_ERROR        | CODING_ERROR     |

### `SUM_CODE`

| case | method   | source_status_1     | source_status_2     | expected_status  |
|-----:|:---------|:--------------------|:--------------------|:-----------------|
|    1 | SUM_CODE | VALUE_CHANGED       | VALUE_CHANGED       | CODING_COMPLETE  |
|    2 | SUM_CODE | VALUE_CHANGED       | CODING_COMPLETE     | INVALID          |
|    3 | SUM_CODE | VALUE_CHANGED       | INTENDED_INCOMPLETE | INVALID          |
|    4 | SUM_CODE | VALUE_CHANGED       | CODING_INCOMPLETE   | INVALID          |
|    5 | SUM_CODE | VALUE_CHANGED       | DERIVE_PENDING      | INVALID          |
|    6 | SUM_CODE | VALUE_CHANGED       | UNSET               | UNSET            |
|    7 | SUM_CODE | VALUE_CHANGED       | NOT_REACHED         | INVALID          |
|    8 | SUM_CODE | VALUE_CHANGED       | DISPLAYED           | INVALID          |
|    9 | SUM_CODE | VALUE_CHANGED       | PARTLY_DISPLAYED    | INVALID          |
|   10 | SUM_CODE | VALUE_CHANGED       | DERIVE_ERROR        | DERIVE_ERROR     |
|   11 | SUM_CODE | VALUE_CHANGED       | NO_CODING           | DERIVE_ERROR     |
|   12 | SUM_CODE | VALUE_CHANGED       | INVALID             | INVALID          |
|   13 | SUM_CODE | VALUE_CHANGED       | CODING_ERROR        | CODING_ERROR     |
|   14 | SUM_CODE | CODING_COMPLETE     | VALUE_CHANGED       | INVALID          |
|   15 | SUM_CODE | CODING_COMPLETE     | CODING_COMPLETE     | CODING_COMPLETE  |
|   16 | SUM_CODE | CODING_COMPLETE     | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   17 | SUM_CODE | CODING_COMPLETE     | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   18 | SUM_CODE | CODING_COMPLETE     | DERIVE_PENDING      | DERIVE_PENDING   |
|   19 | SUM_CODE | CODING_COMPLETE     | UNSET               | UNSET            |
|   20 | SUM_CODE | CODING_COMPLETE     | NOT_REACHED         | INVALID          |
|   21 | SUM_CODE | CODING_COMPLETE     | DISPLAYED           | INVALID          |
|   22 | SUM_CODE | CODING_COMPLETE     | PARTLY_DISPLAYED    | INVALID          |
|   23 | SUM_CODE | CODING_COMPLETE     | DERIVE_ERROR        | DERIVE_ERROR     |
|   24 | SUM_CODE | CODING_COMPLETE     | NO_CODING           | DERIVE_ERROR     |
|   25 | SUM_CODE | CODING_COMPLETE     | INVALID             | INVALID          |
|   26 | SUM_CODE | CODING_COMPLETE     | CODING_ERROR        | CODING_ERROR     |
|   27 | SUM_CODE | INTENDED_INCOMPLETE | VALUE_CHANGED       | INVALID          |
|   28 | SUM_CODE | INTENDED_INCOMPLETE | CODING_COMPLETE     | CODING_COMPLETE  |
|   29 | SUM_CODE | INTENDED_INCOMPLETE | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   30 | SUM_CODE | INTENDED_INCOMPLETE | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   31 | SUM_CODE | INTENDED_INCOMPLETE | DERIVE_PENDING      | DERIVE_PENDING   |
|   32 | SUM_CODE | INTENDED_INCOMPLETE | UNSET               | UNSET            |
|   33 | SUM_CODE | INTENDED_INCOMPLETE | NOT_REACHED         | INVALID          |
|   34 | SUM_CODE | INTENDED_INCOMPLETE | DISPLAYED           | INVALID          |
|   35 | SUM_CODE | INTENDED_INCOMPLETE | PARTLY_DISPLAYED    | INVALID          |
|   36 | SUM_CODE | INTENDED_INCOMPLETE | DERIVE_ERROR        | DERIVE_ERROR     |
|   37 | SUM_CODE | INTENDED_INCOMPLETE | NO_CODING           | DERIVE_ERROR     |
|   38 | SUM_CODE | INTENDED_INCOMPLETE | INVALID             | INVALID          |
|   39 | SUM_CODE | INTENDED_INCOMPLETE | CODING_ERROR        | CODING_ERROR     |
|   40 | SUM_CODE | CODING_INCOMPLETE   | VALUE_CHANGED       | INVALID          |
|   41 | SUM_CODE | CODING_INCOMPLETE   | CODING_COMPLETE     | DERIVE_PENDING   |
|   42 | SUM_CODE | CODING_INCOMPLETE   | INTENDED_INCOMPLETE | DERIVE_PENDING   |
|   43 | SUM_CODE | CODING_INCOMPLETE   | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   44 | SUM_CODE | CODING_INCOMPLETE   | DERIVE_PENDING      | DERIVE_PENDING   |
|   45 | SUM_CODE | CODING_INCOMPLETE   | UNSET               | UNSET            |
|   46 | SUM_CODE | CODING_INCOMPLETE   | NOT_REACHED         | INVALID          |
|   47 | SUM_CODE | CODING_INCOMPLETE   | DISPLAYED           | INVALID          |
|   48 | SUM_CODE | CODING_INCOMPLETE   | PARTLY_DISPLAYED    | INVALID          |
|   49 | SUM_CODE | CODING_INCOMPLETE   | DERIVE_ERROR        | DERIVE_ERROR     |
|   50 | SUM_CODE | CODING_INCOMPLETE   | NO_CODING           | DERIVE_ERROR     |
|   51 | SUM_CODE | CODING_INCOMPLETE   | INVALID             | INVALID          |
|   52 | SUM_CODE | CODING_INCOMPLETE   | CODING_ERROR        | CODING_ERROR     |
|   53 | SUM_CODE | DERIVE_PENDING      | VALUE_CHANGED       | INVALID          |
|   54 | SUM_CODE | DERIVE_PENDING      | CODING_COMPLETE     | DERIVE_PENDING   |
|   55 | SUM_CODE | DERIVE_PENDING      | INTENDED_INCOMPLETE | DERIVE_PENDING   |
|   56 | SUM_CODE | DERIVE_PENDING      | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   57 | SUM_CODE | DERIVE_PENDING      | DERIVE_PENDING      | DERIVE_PENDING   |
|   58 | SUM_CODE | DERIVE_PENDING      | UNSET               | UNSET            |
|   59 | SUM_CODE | DERIVE_PENDING      | NOT_REACHED         | INVALID          |
|   60 | SUM_CODE | DERIVE_PENDING      | DISPLAYED           | INVALID          |
|   61 | SUM_CODE | DERIVE_PENDING      | PARTLY_DISPLAYED    | INVALID          |
|   62 | SUM_CODE | DERIVE_PENDING      | DERIVE_ERROR        | DERIVE_ERROR     |
|   63 | SUM_CODE | DERIVE_PENDING      | NO_CODING           | DERIVE_ERROR     |
|   64 | SUM_CODE | DERIVE_PENDING      | INVALID             | INVALID          |
|   65 | SUM_CODE | DERIVE_PENDING      | CODING_ERROR        | CODING_ERROR     |
|   66 | SUM_CODE | UNSET               | VALUE_CHANGED       | UNSET            |
|   67 | SUM_CODE | UNSET               | CODING_COMPLETE     | UNSET            |
|   68 | SUM_CODE | UNSET               | INTENDED_INCOMPLETE | UNSET            |
|   69 | SUM_CODE | UNSET               | CODING_INCOMPLETE   | UNSET            |
|   70 | SUM_CODE | UNSET               | DERIVE_PENDING      | UNSET            |
|   71 | SUM_CODE | UNSET               | UNSET               | UNSET            |
|   72 | SUM_CODE | UNSET               | NOT_REACHED         | UNSET            |
|   73 | SUM_CODE | UNSET               | DISPLAYED           | UNSET            |
|   74 | SUM_CODE | UNSET               | PARTLY_DISPLAYED    | UNSET            |
|   75 | SUM_CODE | UNSET               | DERIVE_ERROR        | UNSET            |
|   76 | SUM_CODE | UNSET               | NO_CODING           | UNSET            |
|   77 | SUM_CODE | UNSET               | INVALID             | UNSET            |
|   78 | SUM_CODE | UNSET               | CODING_ERROR        | UNSET            |
|   79 | SUM_CODE | NOT_REACHED         | VALUE_CHANGED       | INVALID          |
|   80 | SUM_CODE | NOT_REACHED         | CODING_COMPLETE     | INVALID          |
|   81 | SUM_CODE | NOT_REACHED         | INTENDED_INCOMPLETE | INVALID          |
|   82 | SUM_CODE | NOT_REACHED         | CODING_INCOMPLETE   | INVALID          |
|   83 | SUM_CODE | NOT_REACHED         | DERIVE_PENDING      | INVALID          |
|   84 | SUM_CODE | NOT_REACHED         | UNSET               | UNSET            |
|   85 | SUM_CODE | NOT_REACHED         | NOT_REACHED         | NOT_REACHED      |
|   86 | SUM_CODE | NOT_REACHED         | DISPLAYED           | PARTLY_DISPLAYED |
|   87 | SUM_CODE | NOT_REACHED         | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|   88 | SUM_CODE | NOT_REACHED         | DERIVE_ERROR        | DERIVE_ERROR     |
|   89 | SUM_CODE | NOT_REACHED         | NO_CODING           | DERIVE_ERROR     |
|   90 | SUM_CODE | NOT_REACHED         | INVALID             | INVALID          |
|   91 | SUM_CODE | NOT_REACHED         | CODING_ERROR        | CODING_ERROR     |
|   92 | SUM_CODE | DISPLAYED           | VALUE_CHANGED       | INVALID          |
|   93 | SUM_CODE | DISPLAYED           | CODING_COMPLETE     | INVALID          |
|   94 | SUM_CODE | DISPLAYED           | INTENDED_INCOMPLETE | INVALID          |
|   95 | SUM_CODE | DISPLAYED           | CODING_INCOMPLETE   | INVALID          |
|   96 | SUM_CODE | DISPLAYED           | DERIVE_PENDING      | INVALID          |
|   97 | SUM_CODE | DISPLAYED           | UNSET               | UNSET            |
|   98 | SUM_CODE | DISPLAYED           | NOT_REACHED         | PARTLY_DISPLAYED |
|   99 | SUM_CODE | DISPLAYED           | DISPLAYED           | DISPLAYED        |
|  100 | SUM_CODE | DISPLAYED           | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|  101 | SUM_CODE | DISPLAYED           | DERIVE_ERROR        | DERIVE_ERROR     |
|  102 | SUM_CODE | DISPLAYED           | NO_CODING           | DERIVE_ERROR     |
|  103 | SUM_CODE | DISPLAYED           | INVALID             | INVALID          |
|  104 | SUM_CODE | DISPLAYED           | CODING_ERROR        | CODING_ERROR     |
|  105 | SUM_CODE | PARTLY_DISPLAYED    | VALUE_CHANGED       | INVALID          |
|  106 | SUM_CODE | PARTLY_DISPLAYED    | CODING_COMPLETE     | INVALID          |
|  107 | SUM_CODE | PARTLY_DISPLAYED    | INTENDED_INCOMPLETE | INVALID          |
|  108 | SUM_CODE | PARTLY_DISPLAYED    | CODING_INCOMPLETE   | INVALID          |
|  109 | SUM_CODE | PARTLY_DISPLAYED    | DERIVE_PENDING      | INVALID          |
|  110 | SUM_CODE | PARTLY_DISPLAYED    | UNSET               | UNSET            |
|  111 | SUM_CODE | PARTLY_DISPLAYED    | NOT_REACHED         | PARTLY_DISPLAYED |
|  112 | SUM_CODE | PARTLY_DISPLAYED    | DISPLAYED           | PARTLY_DISPLAYED |
|  113 | SUM_CODE | PARTLY_DISPLAYED    | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|  114 | SUM_CODE | PARTLY_DISPLAYED    | DERIVE_ERROR        | DERIVE_ERROR     |
|  115 | SUM_CODE | PARTLY_DISPLAYED    | NO_CODING           | DERIVE_ERROR     |
|  116 | SUM_CODE | PARTLY_DISPLAYED    | INVALID             | INVALID          |
|  117 | SUM_CODE | PARTLY_DISPLAYED    | CODING_ERROR        | CODING_ERROR     |
|  118 | SUM_CODE | DERIVE_ERROR        | VALUE_CHANGED       | DERIVE_ERROR     |
|  119 | SUM_CODE | DERIVE_ERROR        | CODING_COMPLETE     | DERIVE_ERROR     |
|  120 | SUM_CODE | DERIVE_ERROR        | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|  121 | SUM_CODE | DERIVE_ERROR        | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  122 | SUM_CODE | DERIVE_ERROR        | DERIVE_PENDING      | DERIVE_ERROR     |
|  123 | SUM_CODE | DERIVE_ERROR        | UNSET               | UNSET            |
|  124 | SUM_CODE | DERIVE_ERROR        | NOT_REACHED         | DERIVE_ERROR     |
|  125 | SUM_CODE | DERIVE_ERROR        | DISPLAYED           | DERIVE_ERROR     |
|  126 | SUM_CODE | DERIVE_ERROR        | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  127 | SUM_CODE | DERIVE_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  128 | SUM_CODE | DERIVE_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  129 | SUM_CODE | DERIVE_ERROR        | INVALID             | DERIVE_ERROR     |
|  130 | SUM_CODE | DERIVE_ERROR        | CODING_ERROR        | DERIVE_ERROR     |
|  131 | SUM_CODE | NO_CODING           | VALUE_CHANGED       | DERIVE_ERROR     |
|  132 | SUM_CODE | NO_CODING           | CODING_COMPLETE     | DERIVE_ERROR     |
|  133 | SUM_CODE | NO_CODING           | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|  134 | SUM_CODE | NO_CODING           | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  135 | SUM_CODE | NO_CODING           | DERIVE_PENDING      | DERIVE_ERROR     |
|  136 | SUM_CODE | NO_CODING           | UNSET               | UNSET            |
|  137 | SUM_CODE | NO_CODING           | NOT_REACHED         | DERIVE_ERROR     |
|  138 | SUM_CODE | NO_CODING           | DISPLAYED           | DERIVE_ERROR     |
|  139 | SUM_CODE | NO_CODING           | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  140 | SUM_CODE | NO_CODING           | DERIVE_ERROR        | DERIVE_ERROR     |
|  141 | SUM_CODE | NO_CODING           | NO_CODING           | DERIVE_ERROR     |
|  142 | SUM_CODE | NO_CODING           | INVALID             | DERIVE_ERROR     |
|  143 | SUM_CODE | NO_CODING           | CODING_ERROR        | DERIVE_ERROR     |
|  144 | SUM_CODE | INVALID             | VALUE_CHANGED       | INVALID          |
|  145 | SUM_CODE | INVALID             | CODING_COMPLETE     | INVALID          |
|  146 | SUM_CODE | INVALID             | INTENDED_INCOMPLETE | INVALID          |
|  147 | SUM_CODE | INVALID             | CODING_INCOMPLETE   | INVALID          |
|  148 | SUM_CODE | INVALID             | DERIVE_PENDING      | INVALID          |
|  149 | SUM_CODE | INVALID             | UNSET               | UNSET            |
|  150 | SUM_CODE | INVALID             | NOT_REACHED         | INVALID          |
|  151 | SUM_CODE | INVALID             | DISPLAYED           | INVALID          |
|  152 | SUM_CODE | INVALID             | PARTLY_DISPLAYED    | INVALID          |
|  153 | SUM_CODE | INVALID             | DERIVE_ERROR        | DERIVE_ERROR     |
|  154 | SUM_CODE | INVALID             | NO_CODING           | DERIVE_ERROR     |
|  155 | SUM_CODE | INVALID             | INVALID             | INVALID          |
|  156 | SUM_CODE | INVALID             | CODING_ERROR        | CODING_ERROR     |
|  157 | SUM_CODE | CODING_ERROR        | VALUE_CHANGED       | CODING_ERROR     |
|  158 | SUM_CODE | CODING_ERROR        | CODING_COMPLETE     | CODING_ERROR     |
|  159 | SUM_CODE | CODING_ERROR        | INTENDED_INCOMPLETE | CODING_ERROR     |
|  160 | SUM_CODE | CODING_ERROR        | CODING_INCOMPLETE   | CODING_ERROR     |
|  161 | SUM_CODE | CODING_ERROR        | DERIVE_PENDING      | CODING_ERROR     |
|  162 | SUM_CODE | CODING_ERROR        | UNSET               | UNSET            |
|  163 | SUM_CODE | CODING_ERROR        | NOT_REACHED         | CODING_ERROR     |
|  164 | SUM_CODE | CODING_ERROR        | DISPLAYED           | CODING_ERROR     |
|  165 | SUM_CODE | CODING_ERROR        | PARTLY_DISPLAYED    | CODING_ERROR     |
|  166 | SUM_CODE | CODING_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  167 | SUM_CODE | CODING_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  168 | SUM_CODE | CODING_ERROR        | INVALID             | CODING_ERROR     |
|  169 | SUM_CODE | CODING_ERROR        | CODING_ERROR        | CODING_ERROR     |

### `SUM_SCORE`

| case | method    | source_status_1     | source_status_2     | expected_status  |
|-----:|:----------|:--------------------|:--------------------|:-----------------|
|    1 | SUM_SCORE | VALUE_CHANGED       | VALUE_CHANGED       | CODING_COMPLETE  |
|    2 | SUM_SCORE | VALUE_CHANGED       | CODING_COMPLETE     | INVALID          |
|    3 | SUM_SCORE | VALUE_CHANGED       | INTENDED_INCOMPLETE | INVALID          |
|    4 | SUM_SCORE | VALUE_CHANGED       | CODING_INCOMPLETE   | INVALID          |
|    5 | SUM_SCORE | VALUE_CHANGED       | DERIVE_PENDING      | INVALID          |
|    6 | SUM_SCORE | VALUE_CHANGED       | UNSET               | UNSET            |
|    7 | SUM_SCORE | VALUE_CHANGED       | NOT_REACHED         | INVALID          |
|    8 | SUM_SCORE | VALUE_CHANGED       | DISPLAYED           | INVALID          |
|    9 | SUM_SCORE | VALUE_CHANGED       | PARTLY_DISPLAYED    | INVALID          |
|   10 | SUM_SCORE | VALUE_CHANGED       | DERIVE_ERROR        | DERIVE_ERROR     |
|   11 | SUM_SCORE | VALUE_CHANGED       | NO_CODING           | DERIVE_ERROR     |
|   12 | SUM_SCORE | VALUE_CHANGED       | INVALID             | INVALID          |
|   13 | SUM_SCORE | VALUE_CHANGED       | CODING_ERROR        | CODING_ERROR     |
|   14 | SUM_SCORE | CODING_COMPLETE     | VALUE_CHANGED       | INVALID          |
|   15 | SUM_SCORE | CODING_COMPLETE     | CODING_COMPLETE     | CODING_COMPLETE  |
|   16 | SUM_SCORE | CODING_COMPLETE     | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   17 | SUM_SCORE | CODING_COMPLETE     | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   18 | SUM_SCORE | CODING_COMPLETE     | DERIVE_PENDING      | DERIVE_PENDING   |
|   19 | SUM_SCORE | CODING_COMPLETE     | UNSET               | UNSET            |
|   20 | SUM_SCORE | CODING_COMPLETE     | NOT_REACHED         | INVALID          |
|   21 | SUM_SCORE | CODING_COMPLETE     | DISPLAYED           | INVALID          |
|   22 | SUM_SCORE | CODING_COMPLETE     | PARTLY_DISPLAYED    | INVALID          |
|   23 | SUM_SCORE | CODING_COMPLETE     | DERIVE_ERROR        | DERIVE_ERROR     |
|   24 | SUM_SCORE | CODING_COMPLETE     | NO_CODING           | DERIVE_ERROR     |
|   25 | SUM_SCORE | CODING_COMPLETE     | INVALID             | INVALID          |
|   26 | SUM_SCORE | CODING_COMPLETE     | CODING_ERROR        | CODING_ERROR     |
|   27 | SUM_SCORE | INTENDED_INCOMPLETE | VALUE_CHANGED       | INVALID          |
|   28 | SUM_SCORE | INTENDED_INCOMPLETE | CODING_COMPLETE     | CODING_COMPLETE  |
|   29 | SUM_SCORE | INTENDED_INCOMPLETE | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   30 | SUM_SCORE | INTENDED_INCOMPLETE | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   31 | SUM_SCORE | INTENDED_INCOMPLETE | DERIVE_PENDING      | DERIVE_PENDING   |
|   32 | SUM_SCORE | INTENDED_INCOMPLETE | UNSET               | UNSET            |
|   33 | SUM_SCORE | INTENDED_INCOMPLETE | NOT_REACHED         | INVALID          |
|   34 | SUM_SCORE | INTENDED_INCOMPLETE | DISPLAYED           | INVALID          |
|   35 | SUM_SCORE | INTENDED_INCOMPLETE | PARTLY_DISPLAYED    | INVALID          |
|   36 | SUM_SCORE | INTENDED_INCOMPLETE | DERIVE_ERROR        | DERIVE_ERROR     |
|   37 | SUM_SCORE | INTENDED_INCOMPLETE | NO_CODING           | DERIVE_ERROR     |
|   38 | SUM_SCORE | INTENDED_INCOMPLETE | INVALID             | INVALID          |
|   39 | SUM_SCORE | INTENDED_INCOMPLETE | CODING_ERROR        | CODING_ERROR     |
|   40 | SUM_SCORE | CODING_INCOMPLETE   | VALUE_CHANGED       | INVALID          |
|   41 | SUM_SCORE | CODING_INCOMPLETE   | CODING_COMPLETE     | DERIVE_PENDING   |
|   42 | SUM_SCORE | CODING_INCOMPLETE   | INTENDED_INCOMPLETE | DERIVE_PENDING   |
|   43 | SUM_SCORE | CODING_INCOMPLETE   | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   44 | SUM_SCORE | CODING_INCOMPLETE   | DERIVE_PENDING      | DERIVE_PENDING   |
|   45 | SUM_SCORE | CODING_INCOMPLETE   | UNSET               | UNSET            |
|   46 | SUM_SCORE | CODING_INCOMPLETE   | NOT_REACHED         | INVALID          |
|   47 | SUM_SCORE | CODING_INCOMPLETE   | DISPLAYED           | INVALID          |
|   48 | SUM_SCORE | CODING_INCOMPLETE   | PARTLY_DISPLAYED    | INVALID          |
|   49 | SUM_SCORE | CODING_INCOMPLETE   | DERIVE_ERROR        | DERIVE_ERROR     |
|   50 | SUM_SCORE | CODING_INCOMPLETE   | NO_CODING           | DERIVE_ERROR     |
|   51 | SUM_SCORE | CODING_INCOMPLETE   | INVALID             | INVALID          |
|   52 | SUM_SCORE | CODING_INCOMPLETE   | CODING_ERROR        | CODING_ERROR     |
|   53 | SUM_SCORE | DERIVE_PENDING      | VALUE_CHANGED       | INVALID          |
|   54 | SUM_SCORE | DERIVE_PENDING      | CODING_COMPLETE     | DERIVE_PENDING   |
|   55 | SUM_SCORE | DERIVE_PENDING      | INTENDED_INCOMPLETE | DERIVE_PENDING   |
|   56 | SUM_SCORE | DERIVE_PENDING      | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   57 | SUM_SCORE | DERIVE_PENDING      | DERIVE_PENDING      | DERIVE_PENDING   |
|   58 | SUM_SCORE | DERIVE_PENDING      | UNSET               | UNSET            |
|   59 | SUM_SCORE | DERIVE_PENDING      | NOT_REACHED         | INVALID          |
|   60 | SUM_SCORE | DERIVE_PENDING      | DISPLAYED           | INVALID          |
|   61 | SUM_SCORE | DERIVE_PENDING      | PARTLY_DISPLAYED    | INVALID          |
|   62 | SUM_SCORE | DERIVE_PENDING      | DERIVE_ERROR        | DERIVE_ERROR     |
|   63 | SUM_SCORE | DERIVE_PENDING      | NO_CODING           | DERIVE_ERROR     |
|   64 | SUM_SCORE | DERIVE_PENDING      | INVALID             | INVALID          |
|   65 | SUM_SCORE | DERIVE_PENDING      | CODING_ERROR        | CODING_ERROR     |
|   66 | SUM_SCORE | UNSET               | VALUE_CHANGED       | UNSET            |
|   67 | SUM_SCORE | UNSET               | CODING_COMPLETE     | UNSET            |
|   68 | SUM_SCORE | UNSET               | INTENDED_INCOMPLETE | UNSET            |
|   69 | SUM_SCORE | UNSET               | CODING_INCOMPLETE   | UNSET            |
|   70 | SUM_SCORE | UNSET               | DERIVE_PENDING      | UNSET            |
|   71 | SUM_SCORE | UNSET               | UNSET               | UNSET            |
|   72 | SUM_SCORE | UNSET               | NOT_REACHED         | UNSET            |
|   73 | SUM_SCORE | UNSET               | DISPLAYED           | UNSET            |
|   74 | SUM_SCORE | UNSET               | PARTLY_DISPLAYED    | UNSET            |
|   75 | SUM_SCORE | UNSET               | DERIVE_ERROR        | UNSET            |
|   76 | SUM_SCORE | UNSET               | NO_CODING           | UNSET            |
|   77 | SUM_SCORE | UNSET               | INVALID             | UNSET            |
|   78 | SUM_SCORE | UNSET               | CODING_ERROR        | UNSET            |
|   79 | SUM_SCORE | NOT_REACHED         | VALUE_CHANGED       | INVALID          |
|   80 | SUM_SCORE | NOT_REACHED         | CODING_COMPLETE     | INVALID          |
|   81 | SUM_SCORE | NOT_REACHED         | INTENDED_INCOMPLETE | INVALID          |
|   82 | SUM_SCORE | NOT_REACHED         | CODING_INCOMPLETE   | INVALID          |
|   83 | SUM_SCORE | NOT_REACHED         | DERIVE_PENDING      | INVALID          |
|   84 | SUM_SCORE | NOT_REACHED         | UNSET               | UNSET            |
|   85 | SUM_SCORE | NOT_REACHED         | NOT_REACHED         | NOT_REACHED      |
|   86 | SUM_SCORE | NOT_REACHED         | DISPLAYED           | PARTLY_DISPLAYED |
|   87 | SUM_SCORE | NOT_REACHED         | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|   88 | SUM_SCORE | NOT_REACHED         | DERIVE_ERROR        | DERIVE_ERROR     |
|   89 | SUM_SCORE | NOT_REACHED         | NO_CODING           | DERIVE_ERROR     |
|   90 | SUM_SCORE | NOT_REACHED         | INVALID             | INVALID          |
|   91 | SUM_SCORE | NOT_REACHED         | CODING_ERROR        | CODING_ERROR     |
|   92 | SUM_SCORE | DISPLAYED           | VALUE_CHANGED       | INVALID          |
|   93 | SUM_SCORE | DISPLAYED           | CODING_COMPLETE     | INVALID          |
|   94 | SUM_SCORE | DISPLAYED           | INTENDED_INCOMPLETE | INVALID          |
|   95 | SUM_SCORE | DISPLAYED           | CODING_INCOMPLETE   | INVALID          |
|   96 | SUM_SCORE | DISPLAYED           | DERIVE_PENDING      | INVALID          |
|   97 | SUM_SCORE | DISPLAYED           | UNSET               | UNSET            |
|   98 | SUM_SCORE | DISPLAYED           | NOT_REACHED         | PARTLY_DISPLAYED |
|   99 | SUM_SCORE | DISPLAYED           | DISPLAYED           | DISPLAYED        |
|  100 | SUM_SCORE | DISPLAYED           | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|  101 | SUM_SCORE | DISPLAYED           | DERIVE_ERROR        | DERIVE_ERROR     |
|  102 | SUM_SCORE | DISPLAYED           | NO_CODING           | DERIVE_ERROR     |
|  103 | SUM_SCORE | DISPLAYED           | INVALID             | INVALID          |
|  104 | SUM_SCORE | DISPLAYED           | CODING_ERROR        | CODING_ERROR     |
|  105 | SUM_SCORE | PARTLY_DISPLAYED    | VALUE_CHANGED       | INVALID          |
|  106 | SUM_SCORE | PARTLY_DISPLAYED    | CODING_COMPLETE     | INVALID          |
|  107 | SUM_SCORE | PARTLY_DISPLAYED    | INTENDED_INCOMPLETE | INVALID          |
|  108 | SUM_SCORE | PARTLY_DISPLAYED    | CODING_INCOMPLETE   | INVALID          |
|  109 | SUM_SCORE | PARTLY_DISPLAYED    | DERIVE_PENDING      | INVALID          |
|  110 | SUM_SCORE | PARTLY_DISPLAYED    | UNSET               | UNSET            |
|  111 | SUM_SCORE | PARTLY_DISPLAYED    | NOT_REACHED         | PARTLY_DISPLAYED |
|  112 | SUM_SCORE | PARTLY_DISPLAYED    | DISPLAYED           | PARTLY_DISPLAYED |
|  113 | SUM_SCORE | PARTLY_DISPLAYED    | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|  114 | SUM_SCORE | PARTLY_DISPLAYED    | DERIVE_ERROR        | DERIVE_ERROR     |
|  115 | SUM_SCORE | PARTLY_DISPLAYED    | NO_CODING           | DERIVE_ERROR     |
|  116 | SUM_SCORE | PARTLY_DISPLAYED    | INVALID             | INVALID          |
|  117 | SUM_SCORE | PARTLY_DISPLAYED    | CODING_ERROR        | CODING_ERROR     |
|  118 | SUM_SCORE | DERIVE_ERROR        | VALUE_CHANGED       | DERIVE_ERROR     |
|  119 | SUM_SCORE | DERIVE_ERROR        | CODING_COMPLETE     | DERIVE_ERROR     |
|  120 | SUM_SCORE | DERIVE_ERROR        | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|  121 | SUM_SCORE | DERIVE_ERROR        | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  122 | SUM_SCORE | DERIVE_ERROR        | DERIVE_PENDING      | DERIVE_ERROR     |
|  123 | SUM_SCORE | DERIVE_ERROR        | UNSET               | UNSET            |
|  124 | SUM_SCORE | DERIVE_ERROR        | NOT_REACHED         | DERIVE_ERROR     |
|  125 | SUM_SCORE | DERIVE_ERROR        | DISPLAYED           | DERIVE_ERROR     |
|  126 | SUM_SCORE | DERIVE_ERROR        | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  127 | SUM_SCORE | DERIVE_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  128 | SUM_SCORE | DERIVE_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  129 | SUM_SCORE | DERIVE_ERROR        | INVALID             | DERIVE_ERROR     |
|  130 | SUM_SCORE | DERIVE_ERROR        | CODING_ERROR        | DERIVE_ERROR     |
|  131 | SUM_SCORE | NO_CODING           | VALUE_CHANGED       | DERIVE_ERROR     |
|  132 | SUM_SCORE | NO_CODING           | CODING_COMPLETE     | DERIVE_ERROR     |
|  133 | SUM_SCORE | NO_CODING           | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|  134 | SUM_SCORE | NO_CODING           | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  135 | SUM_SCORE | NO_CODING           | DERIVE_PENDING      | DERIVE_ERROR     |
|  136 | SUM_SCORE | NO_CODING           | UNSET               | UNSET            |
|  137 | SUM_SCORE | NO_CODING           | NOT_REACHED         | DERIVE_ERROR     |
|  138 | SUM_SCORE | NO_CODING           | DISPLAYED           | DERIVE_ERROR     |
|  139 | SUM_SCORE | NO_CODING           | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  140 | SUM_SCORE | NO_CODING           | DERIVE_ERROR        | DERIVE_ERROR     |
|  141 | SUM_SCORE | NO_CODING           | NO_CODING           | DERIVE_ERROR     |
|  142 | SUM_SCORE | NO_CODING           | INVALID             | DERIVE_ERROR     |
|  143 | SUM_SCORE | NO_CODING           | CODING_ERROR        | DERIVE_ERROR     |
|  144 | SUM_SCORE | INVALID             | VALUE_CHANGED       | INVALID          |
|  145 | SUM_SCORE | INVALID             | CODING_COMPLETE     | INVALID          |
|  146 | SUM_SCORE | INVALID             | INTENDED_INCOMPLETE | INVALID          |
|  147 | SUM_SCORE | INVALID             | CODING_INCOMPLETE   | INVALID          |
|  148 | SUM_SCORE | INVALID             | DERIVE_PENDING      | INVALID          |
|  149 | SUM_SCORE | INVALID             | UNSET               | UNSET            |
|  150 | SUM_SCORE | INVALID             | NOT_REACHED         | INVALID          |
|  151 | SUM_SCORE | INVALID             | DISPLAYED           | INVALID          |
|  152 | SUM_SCORE | INVALID             | PARTLY_DISPLAYED    | INVALID          |
|  153 | SUM_SCORE | INVALID             | DERIVE_ERROR        | DERIVE_ERROR     |
|  154 | SUM_SCORE | INVALID             | NO_CODING           | DERIVE_ERROR     |
|  155 | SUM_SCORE | INVALID             | INVALID             | INVALID          |
|  156 | SUM_SCORE | INVALID             | CODING_ERROR        | CODING_ERROR     |
|  157 | SUM_SCORE | CODING_ERROR        | VALUE_CHANGED       | CODING_ERROR     |
|  158 | SUM_SCORE | CODING_ERROR        | CODING_COMPLETE     | CODING_ERROR     |
|  159 | SUM_SCORE | CODING_ERROR        | INTENDED_INCOMPLETE | CODING_ERROR     |
|  160 | SUM_SCORE | CODING_ERROR        | CODING_INCOMPLETE   | CODING_ERROR     |
|  161 | SUM_SCORE | CODING_ERROR        | DERIVE_PENDING      | CODING_ERROR     |
|  162 | SUM_SCORE | CODING_ERROR        | UNSET               | UNSET            |
|  163 | SUM_SCORE | CODING_ERROR        | NOT_REACHED         | CODING_ERROR     |
|  164 | SUM_SCORE | CODING_ERROR        | DISPLAYED           | CODING_ERROR     |
|  165 | SUM_SCORE | CODING_ERROR        | PARTLY_DISPLAYED    | CODING_ERROR     |
|  166 | SUM_SCORE | CODING_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  167 | SUM_SCORE | CODING_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  168 | SUM_SCORE | CODING_ERROR        | INVALID             | CODING_ERROR     |
|  169 | SUM_SCORE | CODING_ERROR        | CODING_ERROR        | CODING_ERROR     |

### `UNIQUE_VALUES`

| case | method        | source_status_1     | source_status_2     | expected_status  |
|-----:|:--------------|:--------------------|:--------------------|:-----------------|
|    1 | UNIQUE_VALUES | VALUE_CHANGED       | VALUE_CHANGED       | CODING_COMPLETE  |
|    2 | UNIQUE_VALUES | VALUE_CHANGED       | CODING_COMPLETE     | CODING_COMPLETE  |
|    3 | UNIQUE_VALUES | VALUE_CHANGED       | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|    4 | UNIQUE_VALUES | VALUE_CHANGED       | CODING_INCOMPLETE   | CODING_COMPLETE  |
|    5 | UNIQUE_VALUES | VALUE_CHANGED       | DERIVE_PENDING      | INVALID          |
|    6 | UNIQUE_VALUES | VALUE_CHANGED       | UNSET               | UNSET            |
|    7 | UNIQUE_VALUES | VALUE_CHANGED       | NOT_REACHED         | INVALID          |
|    8 | UNIQUE_VALUES | VALUE_CHANGED       | DISPLAYED           | INVALID          |
|    9 | UNIQUE_VALUES | VALUE_CHANGED       | PARTLY_DISPLAYED    | INVALID          |
|   10 | UNIQUE_VALUES | VALUE_CHANGED       | DERIVE_ERROR        | DERIVE_ERROR     |
|   11 | UNIQUE_VALUES | VALUE_CHANGED       | NO_CODING           | DERIVE_ERROR     |
|   12 | UNIQUE_VALUES | VALUE_CHANGED       | INVALID             | INVALID          |
|   13 | UNIQUE_VALUES | VALUE_CHANGED       | CODING_ERROR        | CODING_ERROR     |
|   14 | UNIQUE_VALUES | CODING_COMPLETE     | VALUE_CHANGED       | CODING_COMPLETE  |
|   15 | UNIQUE_VALUES | CODING_COMPLETE     | CODING_COMPLETE     | CODING_COMPLETE  |
|   16 | UNIQUE_VALUES | CODING_COMPLETE     | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   17 | UNIQUE_VALUES | CODING_COMPLETE     | CODING_INCOMPLETE   | CODING_COMPLETE  |
|   18 | UNIQUE_VALUES | CODING_COMPLETE     | DERIVE_PENDING      | INVALID          |
|   19 | UNIQUE_VALUES | CODING_COMPLETE     | UNSET               | UNSET            |
|   20 | UNIQUE_VALUES | CODING_COMPLETE     | NOT_REACHED         | INVALID          |
|   21 | UNIQUE_VALUES | CODING_COMPLETE     | DISPLAYED           | INVALID          |
|   22 | UNIQUE_VALUES | CODING_COMPLETE     | PARTLY_DISPLAYED    | INVALID          |
|   23 | UNIQUE_VALUES | CODING_COMPLETE     | DERIVE_ERROR        | DERIVE_ERROR     |
|   24 | UNIQUE_VALUES | CODING_COMPLETE     | NO_CODING           | DERIVE_ERROR     |
|   25 | UNIQUE_VALUES | CODING_COMPLETE     | INVALID             | INVALID          |
|   26 | UNIQUE_VALUES | CODING_COMPLETE     | CODING_ERROR        | CODING_ERROR     |
|   27 | UNIQUE_VALUES | INTENDED_INCOMPLETE | VALUE_CHANGED       | CODING_COMPLETE  |
|   28 | UNIQUE_VALUES | INTENDED_INCOMPLETE | CODING_COMPLETE     | CODING_COMPLETE  |
|   29 | UNIQUE_VALUES | INTENDED_INCOMPLETE | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   30 | UNIQUE_VALUES | INTENDED_INCOMPLETE | CODING_INCOMPLETE   | CODING_COMPLETE  |
|   31 | UNIQUE_VALUES | INTENDED_INCOMPLETE | DERIVE_PENDING      | INVALID          |
|   32 | UNIQUE_VALUES | INTENDED_INCOMPLETE | UNSET               | UNSET            |
|   33 | UNIQUE_VALUES | INTENDED_INCOMPLETE | NOT_REACHED         | INVALID          |
|   34 | UNIQUE_VALUES | INTENDED_INCOMPLETE | DISPLAYED           | INVALID          |
|   35 | UNIQUE_VALUES | INTENDED_INCOMPLETE | PARTLY_DISPLAYED    | INVALID          |
|   36 | UNIQUE_VALUES | INTENDED_INCOMPLETE | DERIVE_ERROR        | DERIVE_ERROR     |
|   37 | UNIQUE_VALUES | INTENDED_INCOMPLETE | NO_CODING           | DERIVE_ERROR     |
|   38 | UNIQUE_VALUES | INTENDED_INCOMPLETE | INVALID             | INVALID          |
|   39 | UNIQUE_VALUES | INTENDED_INCOMPLETE | CODING_ERROR        | CODING_ERROR     |
|   40 | UNIQUE_VALUES | CODING_INCOMPLETE   | VALUE_CHANGED       | CODING_COMPLETE  |
|   41 | UNIQUE_VALUES | CODING_INCOMPLETE   | CODING_COMPLETE     | CODING_COMPLETE  |
|   42 | UNIQUE_VALUES | CODING_INCOMPLETE   | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   43 | UNIQUE_VALUES | CODING_INCOMPLETE   | CODING_INCOMPLETE   | CODING_COMPLETE  |
|   44 | UNIQUE_VALUES | CODING_INCOMPLETE   | DERIVE_PENDING      | INVALID          |
|   45 | UNIQUE_VALUES | CODING_INCOMPLETE   | UNSET               | UNSET            |
|   46 | UNIQUE_VALUES | CODING_INCOMPLETE   | NOT_REACHED         | INVALID          |
|   47 | UNIQUE_VALUES | CODING_INCOMPLETE   | DISPLAYED           | INVALID          |
|   48 | UNIQUE_VALUES | CODING_INCOMPLETE   | PARTLY_DISPLAYED    | INVALID          |
|   49 | UNIQUE_VALUES | CODING_INCOMPLETE   | DERIVE_ERROR        | DERIVE_ERROR     |
|   50 | UNIQUE_VALUES | CODING_INCOMPLETE   | NO_CODING           | DERIVE_ERROR     |
|   51 | UNIQUE_VALUES | CODING_INCOMPLETE   | INVALID             | INVALID          |
|   52 | UNIQUE_VALUES | CODING_INCOMPLETE   | CODING_ERROR        | CODING_ERROR     |
|   53 | UNIQUE_VALUES | DERIVE_PENDING      | VALUE_CHANGED       | INVALID          |
|   54 | UNIQUE_VALUES | DERIVE_PENDING      | CODING_COMPLETE     | INVALID          |
|   55 | UNIQUE_VALUES | DERIVE_PENDING      | INTENDED_INCOMPLETE | INVALID          |
|   56 | UNIQUE_VALUES | DERIVE_PENDING      | CODING_INCOMPLETE   | INVALID          |
|   57 | UNIQUE_VALUES | DERIVE_PENDING      | DERIVE_PENDING      | DERIVE_PENDING   |
|   58 | UNIQUE_VALUES | DERIVE_PENDING      | UNSET               | UNSET            |
|   59 | UNIQUE_VALUES | DERIVE_PENDING      | NOT_REACHED         | INVALID          |
|   60 | UNIQUE_VALUES | DERIVE_PENDING      | DISPLAYED           | INVALID          |
|   61 | UNIQUE_VALUES | DERIVE_PENDING      | PARTLY_DISPLAYED    | INVALID          |
|   62 | UNIQUE_VALUES | DERIVE_PENDING      | DERIVE_ERROR        | DERIVE_ERROR     |
|   63 | UNIQUE_VALUES | DERIVE_PENDING      | NO_CODING           | DERIVE_ERROR     |
|   64 | UNIQUE_VALUES | DERIVE_PENDING      | INVALID             | INVALID          |
|   65 | UNIQUE_VALUES | DERIVE_PENDING      | CODING_ERROR        | CODING_ERROR     |
|   66 | UNIQUE_VALUES | UNSET               | VALUE_CHANGED       | UNSET            |
|   67 | UNIQUE_VALUES | UNSET               | CODING_COMPLETE     | UNSET            |
|   68 | UNIQUE_VALUES | UNSET               | INTENDED_INCOMPLETE | UNSET            |
|   69 | UNIQUE_VALUES | UNSET               | CODING_INCOMPLETE   | UNSET            |
|   70 | UNIQUE_VALUES | UNSET               | DERIVE_PENDING      | UNSET            |
|   71 | UNIQUE_VALUES | UNSET               | UNSET               | UNSET            |
|   72 | UNIQUE_VALUES | UNSET               | NOT_REACHED         | UNSET            |
|   73 | UNIQUE_VALUES | UNSET               | DISPLAYED           | UNSET            |
|   74 | UNIQUE_VALUES | UNSET               | PARTLY_DISPLAYED    | UNSET            |
|   75 | UNIQUE_VALUES | UNSET               | DERIVE_ERROR        | UNSET            |
|   76 | UNIQUE_VALUES | UNSET               | NO_CODING           | UNSET            |
|   77 | UNIQUE_VALUES | UNSET               | INVALID             | UNSET            |
|   78 | UNIQUE_VALUES | UNSET               | CODING_ERROR        | UNSET            |
|   79 | UNIQUE_VALUES | NOT_REACHED         | VALUE_CHANGED       | INVALID          |
|   80 | UNIQUE_VALUES | NOT_REACHED         | CODING_COMPLETE     | INVALID          |
|   81 | UNIQUE_VALUES | NOT_REACHED         | INTENDED_INCOMPLETE | INVALID          |
|   82 | UNIQUE_VALUES | NOT_REACHED         | CODING_INCOMPLETE   | INVALID          |
|   83 | UNIQUE_VALUES | NOT_REACHED         | DERIVE_PENDING      | INVALID          |
|   84 | UNIQUE_VALUES | NOT_REACHED         | UNSET               | UNSET            |
|   85 | UNIQUE_VALUES | NOT_REACHED         | NOT_REACHED         | NOT_REACHED      |
|   86 | UNIQUE_VALUES | NOT_REACHED         | DISPLAYED           | PARTLY_DISPLAYED |
|   87 | UNIQUE_VALUES | NOT_REACHED         | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|   88 | UNIQUE_VALUES | NOT_REACHED         | DERIVE_ERROR        | DERIVE_ERROR     |
|   89 | UNIQUE_VALUES | NOT_REACHED         | NO_CODING           | DERIVE_ERROR     |
|   90 | UNIQUE_VALUES | NOT_REACHED         | INVALID             | INVALID          |
|   91 | UNIQUE_VALUES | NOT_REACHED         | CODING_ERROR        | CODING_ERROR     |
|   92 | UNIQUE_VALUES | DISPLAYED           | VALUE_CHANGED       | INVALID          |
|   93 | UNIQUE_VALUES | DISPLAYED           | CODING_COMPLETE     | INVALID          |
|   94 | UNIQUE_VALUES | DISPLAYED           | INTENDED_INCOMPLETE | INVALID          |
|   95 | UNIQUE_VALUES | DISPLAYED           | CODING_INCOMPLETE   | INVALID          |
|   96 | UNIQUE_VALUES | DISPLAYED           | DERIVE_PENDING      | INVALID          |
|   97 | UNIQUE_VALUES | DISPLAYED           | UNSET               | UNSET            |
|   98 | UNIQUE_VALUES | DISPLAYED           | NOT_REACHED         | PARTLY_DISPLAYED |
|   99 | UNIQUE_VALUES | DISPLAYED           | DISPLAYED           | DISPLAYED        |
|  100 | UNIQUE_VALUES | DISPLAYED           | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|  101 | UNIQUE_VALUES | DISPLAYED           | DERIVE_ERROR        | DERIVE_ERROR     |
|  102 | UNIQUE_VALUES | DISPLAYED           | NO_CODING           | DERIVE_ERROR     |
|  103 | UNIQUE_VALUES | DISPLAYED           | INVALID             | INVALID          |
|  104 | UNIQUE_VALUES | DISPLAYED           | CODING_ERROR        | CODING_ERROR     |
|  105 | UNIQUE_VALUES | PARTLY_DISPLAYED    | VALUE_CHANGED       | INVALID          |
|  106 | UNIQUE_VALUES | PARTLY_DISPLAYED    | CODING_COMPLETE     | INVALID          |
|  107 | UNIQUE_VALUES | PARTLY_DISPLAYED    | INTENDED_INCOMPLETE | INVALID          |
|  108 | UNIQUE_VALUES | PARTLY_DISPLAYED    | CODING_INCOMPLETE   | INVALID          |
|  109 | UNIQUE_VALUES | PARTLY_DISPLAYED    | DERIVE_PENDING      | INVALID          |
|  110 | UNIQUE_VALUES | PARTLY_DISPLAYED    | UNSET               | UNSET            |
|  111 | UNIQUE_VALUES | PARTLY_DISPLAYED    | NOT_REACHED         | PARTLY_DISPLAYED |
|  112 | UNIQUE_VALUES | PARTLY_DISPLAYED    | DISPLAYED           | PARTLY_DISPLAYED |
|  113 | UNIQUE_VALUES | PARTLY_DISPLAYED    | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|  114 | UNIQUE_VALUES | PARTLY_DISPLAYED    | DERIVE_ERROR        | DERIVE_ERROR     |
|  115 | UNIQUE_VALUES | PARTLY_DISPLAYED    | NO_CODING           | DERIVE_ERROR     |
|  116 | UNIQUE_VALUES | PARTLY_DISPLAYED    | INVALID             | INVALID          |
|  117 | UNIQUE_VALUES | PARTLY_DISPLAYED    | CODING_ERROR        | CODING_ERROR     |
|  118 | UNIQUE_VALUES | DERIVE_ERROR        | VALUE_CHANGED       | DERIVE_ERROR     |
|  119 | UNIQUE_VALUES | DERIVE_ERROR        | CODING_COMPLETE     | DERIVE_ERROR     |
|  120 | UNIQUE_VALUES | DERIVE_ERROR        | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|  121 | UNIQUE_VALUES | DERIVE_ERROR        | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  122 | UNIQUE_VALUES | DERIVE_ERROR        | DERIVE_PENDING      | DERIVE_ERROR     |
|  123 | UNIQUE_VALUES | DERIVE_ERROR        | UNSET               | UNSET            |
|  124 | UNIQUE_VALUES | DERIVE_ERROR        | NOT_REACHED         | DERIVE_ERROR     |
|  125 | UNIQUE_VALUES | DERIVE_ERROR        | DISPLAYED           | DERIVE_ERROR     |
|  126 | UNIQUE_VALUES | DERIVE_ERROR        | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  127 | UNIQUE_VALUES | DERIVE_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  128 | UNIQUE_VALUES | DERIVE_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  129 | UNIQUE_VALUES | DERIVE_ERROR        | INVALID             | DERIVE_ERROR     |
|  130 | UNIQUE_VALUES | DERIVE_ERROR        | CODING_ERROR        | DERIVE_ERROR     |
|  131 | UNIQUE_VALUES | NO_CODING           | VALUE_CHANGED       | DERIVE_ERROR     |
|  132 | UNIQUE_VALUES | NO_CODING           | CODING_COMPLETE     | DERIVE_ERROR     |
|  133 | UNIQUE_VALUES | NO_CODING           | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|  134 | UNIQUE_VALUES | NO_CODING           | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  135 | UNIQUE_VALUES | NO_CODING           | DERIVE_PENDING      | DERIVE_ERROR     |
|  136 | UNIQUE_VALUES | NO_CODING           | UNSET               | UNSET            |
|  137 | UNIQUE_VALUES | NO_CODING           | NOT_REACHED         | DERIVE_ERROR     |
|  138 | UNIQUE_VALUES | NO_CODING           | DISPLAYED           | DERIVE_ERROR     |
|  139 | UNIQUE_VALUES | NO_CODING           | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  140 | UNIQUE_VALUES | NO_CODING           | DERIVE_ERROR        | DERIVE_ERROR     |
|  141 | UNIQUE_VALUES | NO_CODING           | NO_CODING           | DERIVE_ERROR     |
|  142 | UNIQUE_VALUES | NO_CODING           | INVALID             | DERIVE_ERROR     |
|  143 | UNIQUE_VALUES | NO_CODING           | CODING_ERROR        | DERIVE_ERROR     |
|  144 | UNIQUE_VALUES | INVALID             | VALUE_CHANGED       | INVALID          |
|  145 | UNIQUE_VALUES | INVALID             | CODING_COMPLETE     | INVALID          |
|  146 | UNIQUE_VALUES | INVALID             | INTENDED_INCOMPLETE | INVALID          |
|  147 | UNIQUE_VALUES | INVALID             | CODING_INCOMPLETE   | INVALID          |
|  148 | UNIQUE_VALUES | INVALID             | DERIVE_PENDING      | INVALID          |
|  149 | UNIQUE_VALUES | INVALID             | UNSET               | UNSET            |
|  150 | UNIQUE_VALUES | INVALID             | NOT_REACHED         | INVALID          |
|  151 | UNIQUE_VALUES | INVALID             | DISPLAYED           | INVALID          |
|  152 | UNIQUE_VALUES | INVALID             | PARTLY_DISPLAYED    | INVALID          |
|  153 | UNIQUE_VALUES | INVALID             | DERIVE_ERROR        | DERIVE_ERROR     |
|  154 | UNIQUE_VALUES | INVALID             | NO_CODING           | DERIVE_ERROR     |
|  155 | UNIQUE_VALUES | INVALID             | INVALID             | INVALID          |
|  156 | UNIQUE_VALUES | INVALID             | CODING_ERROR        | CODING_ERROR     |
|  157 | UNIQUE_VALUES | CODING_ERROR        | VALUE_CHANGED       | CODING_ERROR     |
|  158 | UNIQUE_VALUES | CODING_ERROR        | CODING_COMPLETE     | CODING_ERROR     |
|  159 | UNIQUE_VALUES | CODING_ERROR        | INTENDED_INCOMPLETE | CODING_ERROR     |
|  160 | UNIQUE_VALUES | CODING_ERROR        | CODING_INCOMPLETE   | CODING_ERROR     |
|  161 | UNIQUE_VALUES | CODING_ERROR        | DERIVE_PENDING      | CODING_ERROR     |
|  162 | UNIQUE_VALUES | CODING_ERROR        | UNSET               | UNSET            |
|  163 | UNIQUE_VALUES | CODING_ERROR        | NOT_REACHED         | CODING_ERROR     |
|  164 | UNIQUE_VALUES | CODING_ERROR        | DISPLAYED           | CODING_ERROR     |
|  165 | UNIQUE_VALUES | CODING_ERROR        | PARTLY_DISPLAYED    | CODING_ERROR     |
|  166 | UNIQUE_VALUES | CODING_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  167 | UNIQUE_VALUES | CODING_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  168 | UNIQUE_VALUES | CODING_ERROR        | INVALID             | CODING_ERROR     |
|  169 | UNIQUE_VALUES | CODING_ERROR        | CODING_ERROR        | CODING_ERROR     |

### `SOLVER`

| case | method | source_status_1     | source_status_2     | expected_status  |
|-----:|:-------|:--------------------|:--------------------|:-----------------|
|    1 | SOLVER | VALUE_CHANGED       | VALUE_CHANGED       | CODING_COMPLETE  |
|    2 | SOLVER | VALUE_CHANGED       | CODING_COMPLETE     | CODING_COMPLETE  |
|    3 | SOLVER | VALUE_CHANGED       | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|    4 | SOLVER | VALUE_CHANGED       | CODING_INCOMPLETE   | CODING_COMPLETE  |
|    5 | SOLVER | VALUE_CHANGED       | DERIVE_PENDING      | INVALID          |
|    6 | SOLVER | VALUE_CHANGED       | UNSET               | UNSET            |
|    7 | SOLVER | VALUE_CHANGED       | NOT_REACHED         | INVALID          |
|    8 | SOLVER | VALUE_CHANGED       | DISPLAYED           | INVALID          |
|    9 | SOLVER | VALUE_CHANGED       | PARTLY_DISPLAYED    | INVALID          |
|   10 | SOLVER | VALUE_CHANGED       | DERIVE_ERROR        | DERIVE_ERROR     |
|   11 | SOLVER | VALUE_CHANGED       | NO_CODING           | DERIVE_ERROR     |
|   12 | SOLVER | VALUE_CHANGED       | INVALID             | INVALID          |
|   13 | SOLVER | VALUE_CHANGED       | CODING_ERROR        | CODING_ERROR     |
|   14 | SOLVER | CODING_COMPLETE     | VALUE_CHANGED       | CODING_COMPLETE  |
|   15 | SOLVER | CODING_COMPLETE     | CODING_COMPLETE     | CODING_COMPLETE  |
|   16 | SOLVER | CODING_COMPLETE     | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   17 | SOLVER | CODING_COMPLETE     | CODING_INCOMPLETE   | CODING_COMPLETE  |
|   18 | SOLVER | CODING_COMPLETE     | DERIVE_PENDING      | INVALID          |
|   19 | SOLVER | CODING_COMPLETE     | UNSET               | UNSET            |
|   20 | SOLVER | CODING_COMPLETE     | NOT_REACHED         | INVALID          |
|   21 | SOLVER | CODING_COMPLETE     | DISPLAYED           | INVALID          |
|   22 | SOLVER | CODING_COMPLETE     | PARTLY_DISPLAYED    | INVALID          |
|   23 | SOLVER | CODING_COMPLETE     | DERIVE_ERROR        | DERIVE_ERROR     |
|   24 | SOLVER | CODING_COMPLETE     | NO_CODING           | DERIVE_ERROR     |
|   25 | SOLVER | CODING_COMPLETE     | INVALID             | INVALID          |
|   26 | SOLVER | CODING_COMPLETE     | CODING_ERROR        | CODING_ERROR     |
|   27 | SOLVER | INTENDED_INCOMPLETE | VALUE_CHANGED       | CODING_COMPLETE  |
|   28 | SOLVER | INTENDED_INCOMPLETE | CODING_COMPLETE     | CODING_COMPLETE  |
|   29 | SOLVER | INTENDED_INCOMPLETE | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   30 | SOLVER | INTENDED_INCOMPLETE | CODING_INCOMPLETE   | CODING_COMPLETE  |
|   31 | SOLVER | INTENDED_INCOMPLETE | DERIVE_PENDING      | INVALID          |
|   32 | SOLVER | INTENDED_INCOMPLETE | UNSET               | UNSET            |
|   33 | SOLVER | INTENDED_INCOMPLETE | NOT_REACHED         | INVALID          |
|   34 | SOLVER | INTENDED_INCOMPLETE | DISPLAYED           | INVALID          |
|   35 | SOLVER | INTENDED_INCOMPLETE | PARTLY_DISPLAYED    | INVALID          |
|   36 | SOLVER | INTENDED_INCOMPLETE | DERIVE_ERROR        | DERIVE_ERROR     |
|   37 | SOLVER | INTENDED_INCOMPLETE | NO_CODING           | DERIVE_ERROR     |
|   38 | SOLVER | INTENDED_INCOMPLETE | INVALID             | INVALID          |
|   39 | SOLVER | INTENDED_INCOMPLETE | CODING_ERROR        | CODING_ERROR     |
|   40 | SOLVER | CODING_INCOMPLETE   | VALUE_CHANGED       | CODING_COMPLETE  |
|   41 | SOLVER | CODING_INCOMPLETE   | CODING_COMPLETE     | CODING_COMPLETE  |
|   42 | SOLVER | CODING_INCOMPLETE   | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   43 | SOLVER | CODING_INCOMPLETE   | CODING_INCOMPLETE   | CODING_COMPLETE  |
|   44 | SOLVER | CODING_INCOMPLETE   | DERIVE_PENDING      | INVALID          |
|   45 | SOLVER | CODING_INCOMPLETE   | UNSET               | UNSET            |
|   46 | SOLVER | CODING_INCOMPLETE   | NOT_REACHED         | INVALID          |
|   47 | SOLVER | CODING_INCOMPLETE   | DISPLAYED           | INVALID          |
|   48 | SOLVER | CODING_INCOMPLETE   | PARTLY_DISPLAYED    | INVALID          |
|   49 | SOLVER | CODING_INCOMPLETE   | DERIVE_ERROR        | DERIVE_ERROR     |
|   50 | SOLVER | CODING_INCOMPLETE   | NO_CODING           | DERIVE_ERROR     |
|   51 | SOLVER | CODING_INCOMPLETE   | INVALID             | INVALID          |
|   52 | SOLVER | CODING_INCOMPLETE   | CODING_ERROR        | CODING_ERROR     |
|   53 | SOLVER | DERIVE_PENDING      | VALUE_CHANGED       | INVALID          |
|   54 | SOLVER | DERIVE_PENDING      | CODING_COMPLETE     | INVALID          |
|   55 | SOLVER | DERIVE_PENDING      | INTENDED_INCOMPLETE | INVALID          |
|   56 | SOLVER | DERIVE_PENDING      | CODING_INCOMPLETE   | INVALID          |
|   57 | SOLVER | DERIVE_PENDING      | DERIVE_PENDING      | DERIVE_PENDING   |
|   58 | SOLVER | DERIVE_PENDING      | UNSET               | UNSET            |
|   59 | SOLVER | DERIVE_PENDING      | NOT_REACHED         | INVALID          |
|   60 | SOLVER | DERIVE_PENDING      | DISPLAYED           | INVALID          |
|   61 | SOLVER | DERIVE_PENDING      | PARTLY_DISPLAYED    | INVALID          |
|   62 | SOLVER | DERIVE_PENDING      | DERIVE_ERROR        | DERIVE_ERROR     |
|   63 | SOLVER | DERIVE_PENDING      | NO_CODING           | DERIVE_ERROR     |
|   64 | SOLVER | DERIVE_PENDING      | INVALID             | INVALID          |
|   65 | SOLVER | DERIVE_PENDING      | CODING_ERROR        | CODING_ERROR     |
|   66 | SOLVER | UNSET               | VALUE_CHANGED       | UNSET            |
|   67 | SOLVER | UNSET               | CODING_COMPLETE     | UNSET            |
|   68 | SOLVER | UNSET               | INTENDED_INCOMPLETE | UNSET            |
|   69 | SOLVER | UNSET               | CODING_INCOMPLETE   | UNSET            |
|   70 | SOLVER | UNSET               | DERIVE_PENDING      | UNSET            |
|   71 | SOLVER | UNSET               | UNSET               | UNSET            |
|   72 | SOLVER | UNSET               | NOT_REACHED         | UNSET            |
|   73 | SOLVER | UNSET               | DISPLAYED           | UNSET            |
|   74 | SOLVER | UNSET               | PARTLY_DISPLAYED    | UNSET            |
|   75 | SOLVER | UNSET               | DERIVE_ERROR        | UNSET            |
|   76 | SOLVER | UNSET               | NO_CODING           | UNSET            |
|   77 | SOLVER | UNSET               | INVALID             | UNSET            |
|   78 | SOLVER | UNSET               | CODING_ERROR        | UNSET            |
|   79 | SOLVER | NOT_REACHED         | VALUE_CHANGED       | INVALID          |
|   80 | SOLVER | NOT_REACHED         | CODING_COMPLETE     | INVALID          |
|   81 | SOLVER | NOT_REACHED         | INTENDED_INCOMPLETE | INVALID          |
|   82 | SOLVER | NOT_REACHED         | CODING_INCOMPLETE   | INVALID          |
|   83 | SOLVER | NOT_REACHED         | DERIVE_PENDING      | INVALID          |
|   84 | SOLVER | NOT_REACHED         | UNSET               | UNSET            |
|   85 | SOLVER | NOT_REACHED         | NOT_REACHED         | NOT_REACHED      |
|   86 | SOLVER | NOT_REACHED         | DISPLAYED           | PARTLY_DISPLAYED |
|   87 | SOLVER | NOT_REACHED         | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|   88 | SOLVER | NOT_REACHED         | DERIVE_ERROR        | DERIVE_ERROR     |
|   89 | SOLVER | NOT_REACHED         | NO_CODING           | DERIVE_ERROR     |
|   90 | SOLVER | NOT_REACHED         | INVALID             | INVALID          |
|   91 | SOLVER | NOT_REACHED         | CODING_ERROR        | CODING_ERROR     |
|   92 | SOLVER | DISPLAYED           | VALUE_CHANGED       | INVALID          |
|   93 | SOLVER | DISPLAYED           | CODING_COMPLETE     | INVALID          |
|   94 | SOLVER | DISPLAYED           | INTENDED_INCOMPLETE | INVALID          |
|   95 | SOLVER | DISPLAYED           | CODING_INCOMPLETE   | INVALID          |
|   96 | SOLVER | DISPLAYED           | DERIVE_PENDING      | INVALID          |
|   97 | SOLVER | DISPLAYED           | UNSET               | UNSET            |
|   98 | SOLVER | DISPLAYED           | NOT_REACHED         | PARTLY_DISPLAYED |
|   99 | SOLVER | DISPLAYED           | DISPLAYED           | DISPLAYED        |
|  100 | SOLVER | DISPLAYED           | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|  101 | SOLVER | DISPLAYED           | DERIVE_ERROR        | DERIVE_ERROR     |
|  102 | SOLVER | DISPLAYED           | NO_CODING           | DERIVE_ERROR     |
|  103 | SOLVER | DISPLAYED           | INVALID             | INVALID          |
|  104 | SOLVER | DISPLAYED           | CODING_ERROR        | CODING_ERROR     |
|  105 | SOLVER | PARTLY_DISPLAYED    | VALUE_CHANGED       | INVALID          |
|  106 | SOLVER | PARTLY_DISPLAYED    | CODING_COMPLETE     | INVALID          |
|  107 | SOLVER | PARTLY_DISPLAYED    | INTENDED_INCOMPLETE | INVALID          |
|  108 | SOLVER | PARTLY_DISPLAYED    | CODING_INCOMPLETE   | INVALID          |
|  109 | SOLVER | PARTLY_DISPLAYED    | DERIVE_PENDING      | INVALID          |
|  110 | SOLVER | PARTLY_DISPLAYED    | UNSET               | UNSET            |
|  111 | SOLVER | PARTLY_DISPLAYED    | NOT_REACHED         | PARTLY_DISPLAYED |
|  112 | SOLVER | PARTLY_DISPLAYED    | DISPLAYED           | PARTLY_DISPLAYED |
|  113 | SOLVER | PARTLY_DISPLAYED    | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|  114 | SOLVER | PARTLY_DISPLAYED    | DERIVE_ERROR        | DERIVE_ERROR     |
|  115 | SOLVER | PARTLY_DISPLAYED    | NO_CODING           | DERIVE_ERROR     |
|  116 | SOLVER | PARTLY_DISPLAYED    | INVALID             | INVALID          |
|  117 | SOLVER | PARTLY_DISPLAYED    | CODING_ERROR        | CODING_ERROR     |
|  118 | SOLVER | DERIVE_ERROR        | VALUE_CHANGED       | DERIVE_ERROR     |
|  119 | SOLVER | DERIVE_ERROR        | CODING_COMPLETE     | DERIVE_ERROR     |
|  120 | SOLVER | DERIVE_ERROR        | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|  121 | SOLVER | DERIVE_ERROR        | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  122 | SOLVER | DERIVE_ERROR        | DERIVE_PENDING      | DERIVE_ERROR     |
|  123 | SOLVER | DERIVE_ERROR        | UNSET               | UNSET            |
|  124 | SOLVER | DERIVE_ERROR        | NOT_REACHED         | DERIVE_ERROR     |
|  125 | SOLVER | DERIVE_ERROR        | DISPLAYED           | DERIVE_ERROR     |
|  126 | SOLVER | DERIVE_ERROR        | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  127 | SOLVER | DERIVE_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  128 | SOLVER | DERIVE_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  129 | SOLVER | DERIVE_ERROR        | INVALID             | DERIVE_ERROR     |
|  130 | SOLVER | DERIVE_ERROR        | CODING_ERROR        | DERIVE_ERROR     |
|  131 | SOLVER | NO_CODING           | VALUE_CHANGED       | DERIVE_ERROR     |
|  132 | SOLVER | NO_CODING           | CODING_COMPLETE     | DERIVE_ERROR     |
|  133 | SOLVER | NO_CODING           | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|  134 | SOLVER | NO_CODING           | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  135 | SOLVER | NO_CODING           | DERIVE_PENDING      | DERIVE_ERROR     |
|  136 | SOLVER | NO_CODING           | UNSET               | UNSET            |
|  137 | SOLVER | NO_CODING           | NOT_REACHED         | DERIVE_ERROR     |
|  138 | SOLVER | NO_CODING           | DISPLAYED           | DERIVE_ERROR     |
|  139 | SOLVER | NO_CODING           | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  140 | SOLVER | NO_CODING           | DERIVE_ERROR        | DERIVE_ERROR     |
|  141 | SOLVER | NO_CODING           | NO_CODING           | DERIVE_ERROR     |
|  142 | SOLVER | NO_CODING           | INVALID             | DERIVE_ERROR     |
|  143 | SOLVER | NO_CODING           | CODING_ERROR        | DERIVE_ERROR     |
|  144 | SOLVER | INVALID             | VALUE_CHANGED       | INVALID          |
|  145 | SOLVER | INVALID             | CODING_COMPLETE     | INVALID          |
|  146 | SOLVER | INVALID             | INTENDED_INCOMPLETE | INVALID          |
|  147 | SOLVER | INVALID             | CODING_INCOMPLETE   | INVALID          |
|  148 | SOLVER | INVALID             | DERIVE_PENDING      | INVALID          |
|  149 | SOLVER | INVALID             | UNSET               | UNSET            |
|  150 | SOLVER | INVALID             | NOT_REACHED         | INVALID          |
|  151 | SOLVER | INVALID             | DISPLAYED           | INVALID          |
|  152 | SOLVER | INVALID             | PARTLY_DISPLAYED    | INVALID          |
|  153 | SOLVER | INVALID             | DERIVE_ERROR        | DERIVE_ERROR     |
|  154 | SOLVER | INVALID             | NO_CODING           | DERIVE_ERROR     |
|  155 | SOLVER | INVALID             | INVALID             | INVALID          |
|  156 | SOLVER | INVALID             | CODING_ERROR        | CODING_ERROR     |
|  157 | SOLVER | CODING_ERROR        | VALUE_CHANGED       | CODING_ERROR     |
|  158 | SOLVER | CODING_ERROR        | CODING_COMPLETE     | CODING_ERROR     |
|  159 | SOLVER | CODING_ERROR        | INTENDED_INCOMPLETE | CODING_ERROR     |
|  160 | SOLVER | CODING_ERROR        | CODING_INCOMPLETE   | CODING_ERROR     |
|  161 | SOLVER | CODING_ERROR        | DERIVE_PENDING      | CODING_ERROR     |
|  162 | SOLVER | CODING_ERROR        | UNSET               | UNSET            |
|  163 | SOLVER | CODING_ERROR        | NOT_REACHED         | CODING_ERROR     |
|  164 | SOLVER | CODING_ERROR        | DISPLAYED           | CODING_ERROR     |
|  165 | SOLVER | CODING_ERROR        | PARTLY_DISPLAYED    | CODING_ERROR     |
|  166 | SOLVER | CODING_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  167 | SOLVER | CODING_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  168 | SOLVER | CODING_ERROR        | INVALID             | CODING_ERROR     |
|  169 | SOLVER | CODING_ERROR        | CODING_ERROR        | CODING_ERROR     |

### `COPY_VALUE`

| case | method     | source_status       | expected_status  |
|-----:|:-----------|:--------------------|:-----------------|
|    1 | COPY_VALUE | VALUE_CHANGED       | CODING_COMPLETE  |
|    2 | COPY_VALUE | CODING_COMPLETE     | CODING_COMPLETE  |
|    3 | COPY_VALUE | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|    4 | COPY_VALUE | CODING_INCOMPLETE   | CODING_COMPLETE  |
|    5 | COPY_VALUE | DERIVE_PENDING      | DERIVE_PENDING   |
|    6 | COPY_VALUE | UNSET               | UNSET            |
|    7 | COPY_VALUE | NOT_REACHED         | NOT_REACHED      |
|    8 | COPY_VALUE | DISPLAYED           | DISPLAYED        |
|    9 | COPY_VALUE | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|   10 | COPY_VALUE | DERIVE_ERROR        | DERIVE_ERROR     |
|   11 | COPY_VALUE | NO_CODING           | DERIVE_ERROR     |
|   12 | COPY_VALUE | INVALID             | INVALID          |
|   13 | COPY_VALUE | CODING_ERROR        | CODING_ERROR     |
