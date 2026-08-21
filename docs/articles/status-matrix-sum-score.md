# Statusmatrix fuer SUM_SCORE-Ableitungen

Diese Seite dokumentiert die erwartete Statusverrechnung fuer eine
abgeleitete Variable mit `sourceType = "SUM_SCORE"` und zwei
Quellvariablen im aktuellen `eatAutoCode`-Stand mit `@iqb/responses`
5.2.2.

Die Matrix ist als Regressionstest in
`tests/testthat/test-status_matrix_sum_score.R` abgedeckt. Der Test baut
eine vollstaendig geschlossen kodierbare `SUM_SCORE`-Ableitung, prueft
alle `12 * 12 = 144` Statuskreuzungen und vergleicht den vom Autocoder
erzeugten Status mit dem hier dokumentierten Sollstatus.

`VALUE_CHANGED` ist in dieser Matrix bewusst nicht enthalten. Dieser
Status ist ein Zwischenstatus vor der Kodierung von Basisvariablen; als
Quellstatus fuer eine bereits zu aggregierende `SUM_SCORE`-Ableitung
sollte er nach dem vorgelagerten Kodierschritt nicht mehr auftreten.
`CODE_SELECTION_PENDING` ist ebenfalls nicht enthalten, weil es in
`@iqb/responses` 5.2.2 nicht Teil der Autocoder-Statuskonstanten ist.

## Regelreihenfolge

Die Regeln werden von oben nach unten angewandt. Die erste passende
Regel bestimmt den Zielstatus.

| condition | result |
|:---|:---|
| Mindestens eine Quelle ist UNSET. | UNSET |
| Mindestens eine Quelle ist DERIVE_ERROR oder NO_CODING. | DERIVE_ERROR |
| Mindestens eine Quelle ist CODING_ERROR. | CODING_ERROR |
| Mindestens eine Quelle ist INVALID. | INVALID |
| Mindestens eine Quelle ist CODING_INCOMPLETE oder DERIVE_PENDING, und alle Quellen sind CODING_COMPLETE, INTENDED_INCOMPLETE, CODING_INCOMPLETE oder DERIVE_PENDING. | DERIVE_PENDING |
| Mindestens eine Quelle ist in der zulaessigen/Pending-Gruppe, und mindestens eine andere Quelle ist ausserhalb dieser Gruppe. | INVALID |
| Mindestens eine Quelle ist PARTLY_DISPLAYED oder DISPLAYED, und mindestens eine andere Quelle ist NOT_REACHED. | PARTLY_DISPLAYED |
| Mindestens eine Quelle ist PARTLY_DISPLAYED, und mindestens eine andere Quelle ist DISPLAYED. | PARTLY_DISPLAYED |
| Mindestens eine Quelle ist INTENDED_INCOMPLETE, und alle Quellen sind CODING_COMPLETE oder INTENDED_INCOMPLETE. | CODING_COMPLETE |
| Alle Quellen haben denselben Status. | Quellstatus wird uebernommen |

## Vollstaendige Matrix

| case | source_status_1     | source_status_2     | expected_status  |
|-----:|:--------------------|:--------------------|:-----------------|
|    1 | CODING_COMPLETE     | CODING_COMPLETE     | CODING_COMPLETE  |
|    2 | CODING_COMPLETE     | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|    3 | CODING_COMPLETE     | CODING_INCOMPLETE   | DERIVE_PENDING   |
|    4 | CODING_COMPLETE     | DERIVE_PENDING      | DERIVE_PENDING   |
|    5 | CODING_COMPLETE     | UNSET               | UNSET            |
|    6 | CODING_COMPLETE     | NOT_REACHED         | INVALID          |
|    7 | CODING_COMPLETE     | DISPLAYED           | INVALID          |
|    8 | CODING_COMPLETE     | PARTLY_DISPLAYED    | INVALID          |
|    9 | CODING_COMPLETE     | DERIVE_ERROR        | DERIVE_ERROR     |
|   10 | CODING_COMPLETE     | NO_CODING           | DERIVE_ERROR     |
|   11 | CODING_COMPLETE     | INVALID             | INVALID          |
|   12 | CODING_COMPLETE     | CODING_ERROR        | CODING_ERROR     |
|   13 | INTENDED_INCOMPLETE | CODING_COMPLETE     | CODING_COMPLETE  |
|   14 | INTENDED_INCOMPLETE | INTENDED_INCOMPLETE | CODING_COMPLETE  |
|   15 | INTENDED_INCOMPLETE | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   16 | INTENDED_INCOMPLETE | DERIVE_PENDING      | DERIVE_PENDING   |
|   17 | INTENDED_INCOMPLETE | UNSET               | UNSET            |
|   18 | INTENDED_INCOMPLETE | NOT_REACHED         | INVALID          |
|   19 | INTENDED_INCOMPLETE | DISPLAYED           | INVALID          |
|   20 | INTENDED_INCOMPLETE | PARTLY_DISPLAYED    | INVALID          |
|   21 | INTENDED_INCOMPLETE | DERIVE_ERROR        | DERIVE_ERROR     |
|   22 | INTENDED_INCOMPLETE | NO_CODING           | DERIVE_ERROR     |
|   23 | INTENDED_INCOMPLETE | INVALID             | INVALID          |
|   24 | INTENDED_INCOMPLETE | CODING_ERROR        | CODING_ERROR     |
|   25 | CODING_INCOMPLETE   | CODING_COMPLETE     | DERIVE_PENDING   |
|   26 | CODING_INCOMPLETE   | INTENDED_INCOMPLETE | DERIVE_PENDING   |
|   27 | CODING_INCOMPLETE   | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   28 | CODING_INCOMPLETE   | DERIVE_PENDING      | DERIVE_PENDING   |
|   29 | CODING_INCOMPLETE   | UNSET               | UNSET            |
|   30 | CODING_INCOMPLETE   | NOT_REACHED         | INVALID          |
|   31 | CODING_INCOMPLETE   | DISPLAYED           | INVALID          |
|   32 | CODING_INCOMPLETE   | PARTLY_DISPLAYED    | INVALID          |
|   33 | CODING_INCOMPLETE   | DERIVE_ERROR        | DERIVE_ERROR     |
|   34 | CODING_INCOMPLETE   | NO_CODING           | DERIVE_ERROR     |
|   35 | CODING_INCOMPLETE   | INVALID             | INVALID          |
|   36 | CODING_INCOMPLETE   | CODING_ERROR        | CODING_ERROR     |
|   37 | DERIVE_PENDING      | CODING_COMPLETE     | DERIVE_PENDING   |
|   38 | DERIVE_PENDING      | INTENDED_INCOMPLETE | DERIVE_PENDING   |
|   39 | DERIVE_PENDING      | CODING_INCOMPLETE   | DERIVE_PENDING   |
|   40 | DERIVE_PENDING      | DERIVE_PENDING      | DERIVE_PENDING   |
|   41 | DERIVE_PENDING      | UNSET               | UNSET            |
|   42 | DERIVE_PENDING      | NOT_REACHED         | INVALID          |
|   43 | DERIVE_PENDING      | DISPLAYED           | INVALID          |
|   44 | DERIVE_PENDING      | PARTLY_DISPLAYED    | INVALID          |
|   45 | DERIVE_PENDING      | DERIVE_ERROR        | DERIVE_ERROR     |
|   46 | DERIVE_PENDING      | NO_CODING           | DERIVE_ERROR     |
|   47 | DERIVE_PENDING      | INVALID             | INVALID          |
|   48 | DERIVE_PENDING      | CODING_ERROR        | CODING_ERROR     |
|   49 | UNSET               | CODING_COMPLETE     | UNSET            |
|   50 | UNSET               | INTENDED_INCOMPLETE | UNSET            |
|   51 | UNSET               | CODING_INCOMPLETE   | UNSET            |
|   52 | UNSET               | DERIVE_PENDING      | UNSET            |
|   53 | UNSET               | UNSET               | UNSET            |
|   54 | UNSET               | NOT_REACHED         | UNSET            |
|   55 | UNSET               | DISPLAYED           | UNSET            |
|   56 | UNSET               | PARTLY_DISPLAYED    | UNSET            |
|   57 | UNSET               | DERIVE_ERROR        | UNSET            |
|   58 | UNSET               | NO_CODING           | UNSET            |
|   59 | UNSET               | INVALID             | UNSET            |
|   60 | UNSET               | CODING_ERROR        | UNSET            |
|   61 | NOT_REACHED         | CODING_COMPLETE     | INVALID          |
|   62 | NOT_REACHED         | INTENDED_INCOMPLETE | INVALID          |
|   63 | NOT_REACHED         | CODING_INCOMPLETE   | INVALID          |
|   64 | NOT_REACHED         | DERIVE_PENDING      | INVALID          |
|   65 | NOT_REACHED         | UNSET               | UNSET            |
|   66 | NOT_REACHED         | NOT_REACHED         | NOT_REACHED      |
|   67 | NOT_REACHED         | DISPLAYED           | PARTLY_DISPLAYED |
|   68 | NOT_REACHED         | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|   69 | NOT_REACHED         | DERIVE_ERROR        | DERIVE_ERROR     |
|   70 | NOT_REACHED         | NO_CODING           | DERIVE_ERROR     |
|   71 | NOT_REACHED         | INVALID             | INVALID          |
|   72 | NOT_REACHED         | CODING_ERROR        | CODING_ERROR     |
|   73 | DISPLAYED           | CODING_COMPLETE     | INVALID          |
|   74 | DISPLAYED           | INTENDED_INCOMPLETE | INVALID          |
|   75 | DISPLAYED           | CODING_INCOMPLETE   | INVALID          |
|   76 | DISPLAYED           | DERIVE_PENDING      | INVALID          |
|   77 | DISPLAYED           | UNSET               | UNSET            |
|   78 | DISPLAYED           | NOT_REACHED         | PARTLY_DISPLAYED |
|   79 | DISPLAYED           | DISPLAYED           | DISPLAYED        |
|   80 | DISPLAYED           | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|   81 | DISPLAYED           | DERIVE_ERROR        | DERIVE_ERROR     |
|   82 | DISPLAYED           | NO_CODING           | DERIVE_ERROR     |
|   83 | DISPLAYED           | INVALID             | INVALID          |
|   84 | DISPLAYED           | CODING_ERROR        | CODING_ERROR     |
|   85 | PARTLY_DISPLAYED    | CODING_COMPLETE     | INVALID          |
|   86 | PARTLY_DISPLAYED    | INTENDED_INCOMPLETE | INVALID          |
|   87 | PARTLY_DISPLAYED    | CODING_INCOMPLETE   | INVALID          |
|   88 | PARTLY_DISPLAYED    | DERIVE_PENDING      | INVALID          |
|   89 | PARTLY_DISPLAYED    | UNSET               | UNSET            |
|   90 | PARTLY_DISPLAYED    | NOT_REACHED         | PARTLY_DISPLAYED |
|   91 | PARTLY_DISPLAYED    | DISPLAYED           | PARTLY_DISPLAYED |
|   92 | PARTLY_DISPLAYED    | PARTLY_DISPLAYED    | PARTLY_DISPLAYED |
|   93 | PARTLY_DISPLAYED    | DERIVE_ERROR        | DERIVE_ERROR     |
|   94 | PARTLY_DISPLAYED    | NO_CODING           | DERIVE_ERROR     |
|   95 | PARTLY_DISPLAYED    | INVALID             | INVALID          |
|   96 | PARTLY_DISPLAYED    | CODING_ERROR        | CODING_ERROR     |
|   97 | DERIVE_ERROR        | CODING_COMPLETE     | DERIVE_ERROR     |
|   98 | DERIVE_ERROR        | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|   99 | DERIVE_ERROR        | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  100 | DERIVE_ERROR        | DERIVE_PENDING      | DERIVE_ERROR     |
|  101 | DERIVE_ERROR        | UNSET               | UNSET            |
|  102 | DERIVE_ERROR        | NOT_REACHED         | DERIVE_ERROR     |
|  103 | DERIVE_ERROR        | DISPLAYED           | DERIVE_ERROR     |
|  104 | DERIVE_ERROR        | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  105 | DERIVE_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  106 | DERIVE_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  107 | DERIVE_ERROR        | INVALID             | DERIVE_ERROR     |
|  108 | DERIVE_ERROR        | CODING_ERROR        | DERIVE_ERROR     |
|  109 | NO_CODING           | CODING_COMPLETE     | DERIVE_ERROR     |
|  110 | NO_CODING           | INTENDED_INCOMPLETE | DERIVE_ERROR     |
|  111 | NO_CODING           | CODING_INCOMPLETE   | DERIVE_ERROR     |
|  112 | NO_CODING           | DERIVE_PENDING      | DERIVE_ERROR     |
|  113 | NO_CODING           | UNSET               | UNSET            |
|  114 | NO_CODING           | NOT_REACHED         | DERIVE_ERROR     |
|  115 | NO_CODING           | DISPLAYED           | DERIVE_ERROR     |
|  116 | NO_CODING           | PARTLY_DISPLAYED    | DERIVE_ERROR     |
|  117 | NO_CODING           | DERIVE_ERROR        | DERIVE_ERROR     |
|  118 | NO_CODING           | NO_CODING           | DERIVE_ERROR     |
|  119 | NO_CODING           | INVALID             | DERIVE_ERROR     |
|  120 | NO_CODING           | CODING_ERROR        | DERIVE_ERROR     |
|  121 | INVALID             | CODING_COMPLETE     | INVALID          |
|  122 | INVALID             | INTENDED_INCOMPLETE | INVALID          |
|  123 | INVALID             | CODING_INCOMPLETE   | INVALID          |
|  124 | INVALID             | DERIVE_PENDING      | INVALID          |
|  125 | INVALID             | UNSET               | UNSET            |
|  126 | INVALID             | NOT_REACHED         | INVALID          |
|  127 | INVALID             | DISPLAYED           | INVALID          |
|  128 | INVALID             | PARTLY_DISPLAYED    | INVALID          |
|  129 | INVALID             | DERIVE_ERROR        | DERIVE_ERROR     |
|  130 | INVALID             | NO_CODING           | DERIVE_ERROR     |
|  131 | INVALID             | INVALID             | INVALID          |
|  132 | INVALID             | CODING_ERROR        | CODING_ERROR     |
|  133 | CODING_ERROR        | CODING_COMPLETE     | CODING_ERROR     |
|  134 | CODING_ERROR        | INTENDED_INCOMPLETE | CODING_ERROR     |
|  135 | CODING_ERROR        | CODING_INCOMPLETE   | CODING_ERROR     |
|  136 | CODING_ERROR        | DERIVE_PENDING      | CODING_ERROR     |
|  137 | CODING_ERROR        | UNSET               | UNSET            |
|  138 | CODING_ERROR        | NOT_REACHED         | CODING_ERROR     |
|  139 | CODING_ERROR        | DISPLAYED           | CODING_ERROR     |
|  140 | CODING_ERROR        | PARTLY_DISPLAYED    | CODING_ERROR     |
|  141 | CODING_ERROR        | DERIVE_ERROR        | DERIVE_ERROR     |
|  142 | CODING_ERROR        | NO_CODING           | DERIVE_ERROR     |
|  143 | CODING_ERROR        | INVALID             | CODING_ERROR     |
|  144 | CODING_ERROR        | CODING_ERROR        | CODING_ERROR     |
