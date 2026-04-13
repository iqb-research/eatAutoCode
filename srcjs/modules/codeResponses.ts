import { ResponseStatusType } from "@iqbspecs/response/response.interface";
import { CodingSchemeFactory } from "@iqb/responses";
import insertManual from "../helpers/insertManual";
import insertGeometryVariables from "../helpers/insertGeometryVariables";
import deparseJSON from "../helpers/deparseJSON";
import { concatenateValue } from "../helpers/concatenateValue";

type UnitResponses = {
  id: string;
  status: ResponseStatusType;
  value: any;
};

type ManualCodes = {
  id: string;
  status: ResponseStatusType;
  code: number;
};

type GeometryVariablesCodes = {
  id: string;
  status: ResponseStatusType;
  value: any;
};

type UnitsArray = {
  responses: UnitResponses[];
  manual: ManualCodes[];
  geometry_variables: GeometryVariablesCodes[];
};

export function codeResponses(params: {
  codingScheme: any;
  responses: UnitResponses[] | string;
  manual: ManualCodes[] | string | null;
  geometry_variables: GeometryVariablesCodes[] | string | null;
}): UnitResponses[] {
  const { codingScheme, responses, manual, geometry_variables } = params;

  // Parse responses and variableCodings if it's a JSON string
  const { variableCodings }: { variableCodings: any } =
    deparseJSON(codingScheme);
  // const preparedScheme = deparseJSON(codingScheme);

  let responsesToCode: UnitResponses[] = deparseJSON(responses);
  const manualToInsert: ManualCodes[] | null = manual && deparseJSON(manual);
  const geometryVariablesToInsert: GeometryVariablesCodes[] | null =
    geometry_variables && deparseJSON(geometry_variables);

  if (geometryVariablesToInsert !== null) {
    responsesToCode = insertGeometryVariables({
      responses: responsesToCode,
      geometry_variables: geometryVariablesToInsert,
    });
  }

    if (manualToInsert !== null) {
    responsesToCode = insertManual({
      responses: responsesToCode,
      manual: manualToInsert,
    });
  }



  // Create CodingSchemeFactory instance and code responses
  const coded = CodingSchemeFactory.code(responsesToCode, variableCodings);
  return coded;
}

export function codeResponsesArray(params: {
  codingScheme: any;
  responses: UnitsArray[] | string;
  collapse: string;
  wrapStart: string;
  wrapEnd: string;
  missing: string;
}): UnitsArray[] {
  const { codingScheme, responses, collapse, wrapStart, wrapEnd, missing } =
    params;

  // Parse responses and variableCodings if it's a JSON string
  const { variableCodings }: { variableCodings: any } =
    deparseJSON(codingScheme);
  // const preparedScheme = deparseJSON(codingScheme);

  const responsesToCode: UnitsArray[] = deparseJSON(responses);

  const coded = responsesToCode.map((resp) => {
    let responses: UnitResponses[] = deparseJSON(resp.responses);

    const geometryVariablesToInsert: GeometryVariablesCodes[] | null =
      resp?.geometry_variables && deparseJSON(resp.geometry_variables);

    const manualToInsert: ManualCodes[] | null =
      resp?.manual && deparseJSON(resp.manual);

    if (
      geometryVariablesToInsert !== null &&
      geometryVariablesToInsert !== undefined
    ) {
      responses = insertGeometryVariables({
        responses: responses,
        geometry_variables: geometryVariablesToInsert,
      });

      // Delete manual entry as it is not necessary anymore
      delete resp.geometry_variables;
    }

    if (manualToInsert !== null && manualToInsert !== undefined) {
      responses = insertManual({
        responses: responses,
        manual: manualToInsert,
      });

      // Delete manual entry as it is not necessary anymore
      delete resp.manual;
    }

    resp.responses = CodingSchemeFactory.code(responses, variableCodings).map(
      (coded) => {
        coded.value = concatenateValue({
          value: coded.value,
          collapse: collapse,
          wrapStart: wrapStart,
          wrapEnd: wrapEnd,
          missing: missing,
        });

        return coded;
      },
    );

    return resp;
  });

  return coded;
}
