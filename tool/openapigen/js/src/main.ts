import { dereference, load } from '@scalar/openapi-parser';
import { OpenAPIV3 } from '@scalar/openapi-types';
import { isEqual } from 'lodash';

interface OpenAPIGenResult {
  docs?: string;
  schemas: Record<string, OpenAPIV3.SchemaObject>;
  methods: OAPIGenMethods[];
}

interface OAPIGenMethods {
  name?: string; //
  path: string; //
  method: string; //
  summary?: string; //
  description?: string; //
  parameters: OpenAPIV3.ParameterObject[];
  body?:
    | {
        type: string;
        name?: string;
        schema?: OpenAPIV3.SchemaObject;
      }
    | {
        type: undefined;
        name: undefined;
        schema: undefined;
        ref?: string;
      };
  returns?: Record<
    string,
    {
      type: string;
      name?: string;
      schema?: OpenAPIV3.SchemaObject;
    }
  >;
}

/** Parses the OpenAPI document and generates an object map used for generating code */
export async function parseOpenAPIDocumentSource(source: string) {
  // dereference
  const { schema } = await dereference(source);
  if (!schema) throw Error('Schema did not parse');

  // return openapiDocToResult(schema as OpenAPIV3.Document);
  return openapiDocToResult(schema as OpenAPIV3.Document);
}

function openapiDocToResult(spec: OpenAPIV3.Document): OpenAPIGenResult {
  const schemas = spec.components?.schemas ?? {};

  function searchComponent(schema: object): string | undefined {
    return Object.entries(schemas).find(([k, v]) => isEqual(v, schema))?.[0];
  }

  function transformBodySchema(
    responseInfo:
      | OpenAPIV3.ReferenceObject
      | OpenAPIV3.RequestBodyObject
      | undefined,
  ):
    | {
        type: string;
        name?: string;
        schema?: OpenAPIV3.SchemaObject;
        required?: boolean;
      }
    | {
        type: undefined;
        name: undefined;
        schema: undefined;
        ref?: string;
        required?: boolean;
      }
    | undefined {
    if (responseInfo) {
      if ('$ref' in responseInfo) {
        return {
          type: undefined,
          name: undefined,
          schema: undefined,
          ref: responseInfo.$ref,
        };
      } else if (responseInfo?.content) {
        const [[contentType, obj]] = Object.entries(
          responseInfo.content as {
            [media: string]: OpenAPIV3.MediaTypeObject;
          },
        );

        let name = obj.schema?.title
          ? obj.schema.title !== 'schema'
            ? obj.schema?.title
            : 'unknown'
          : undefined;
        if (name === 'unknown') name = searchComponent(obj);

        return {
          type: contentType,
          name,
          schema: obj,
          required: responseInfo.required,
        };
      }
    }
  }

  function generateMethod(
    operation: OpenAPIV3.OperationObject | undefined,
    name: string,
    path: string,
    parameters: OpenAPIV3.ParameterObject[] = [],
  ): OAPIGenMethods {
    return {
      method: name,
      path: path,
      name: operation?.operationId,
      summary: operation?.summary,
      description: operation?.description,
      parameters: [
        ...[
          ...((operation?.parameters as OpenAPIV3.ParameterObject[]) ?? []),
          ...parameters,
        ],
      ],
      body: transformBodySchema(operation?.requestBody),
      returns: Object.assign(
        {},
        ...Object.entries(operation?.responses ?? {}).map(
          ([code, responseInfo]) => {
            const body = transformBodySchema(responseInfo);
            return {
              [code]: body,
            };
          },
        ),
      ),
    };
  }

  return {
    docs: spec.info?.description,
    schemas,
    methods: Object.entries(spec.paths ?? {})
      .map(([k, v]) => {
        const returnArray: OAPIGenMethods[] = [];
        if (v?.get) {
          returnArray.push(
            generateMethod(
              v.get,
              'GET',
              k,
              v.parameters as OpenAPIV3.ParameterObject[],
            ),
          );
        }
        if (v?.post) {
          returnArray.push(
            generateMethod(
              v.post,
              'POST',
              k,
              v.parameters as OpenAPIV3.ParameterObject[],
            ),
          );
        }
        if (v?.delete) {
          returnArray.push(
            generateMethod(
              v.delete,
              'DELETE',
              k,
              v.parameters as OpenAPIV3.ParameterObject[],
            ),
          );
        }
        if (v?.put) {
          returnArray.push(
            generateMethod(
              v.put,
              'PUT',
              k,
              v.parameters as OpenAPIV3.ParameterObject[],
            ),
          );
        }
        return returnArray;
      })
      .reduce((previous, current, index) => previous.concat(current)),
  };
}
