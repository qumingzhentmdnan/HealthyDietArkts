export class ColumnInfo{
  name: string
  columnName: string
  type: ColumnType
}

export enum ColumnType{
  LONG,
  DOUBLE,
  STRING,
  BLOB
}