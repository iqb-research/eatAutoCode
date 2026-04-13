import { ResponseStatusType } from "@iqbspecs/response/response.interface";

type UnitResponses = {
  id: string;
  status: ResponseStatusType;
  value: any;
};

type GeometryVariablesCodes = {
  id: string;
  status: ResponseStatusType;
  value: any;
};

export default function insertGeometryVariables(params: {
  responses: UnitResponses[];
  geometry_variables: GeometryVariablesCodes[];
}): UnitResponses[] {
  const { responses, geometry_variables } = params;

  // Create a lookup object for `geometry_variables`
  const geometryVariablesMap = geometry_variables.reduce((map, item) => {
    map[item.id] = item;
    return map;
  }, {});

  // Update `responses` using the lookup object
  const updatedObj = responses.map((item) =>
    geometryVariablesMap[item.id]
      ? { ...item, ...geometryVariablesMap[item.id] }
      : item,
  );

  // Add new items from `ggb` not in `responses`
  const newItems = geometry_variables.filter(
    (item) => !responses.some((o) => o.id === item.id),
  );

  return [...updatedObj, ...newItems];
}
