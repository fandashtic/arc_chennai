Delete From ParameterInfo Where ParameterID = 641
Insert into ParameterInfo
select 641 ParameterID,ParameterName,ParameterType,DefaultValue,AutoComplete,MultipleInput,OrderBy,DynamicParamID from ParameterInfo Where  ParameterID = 1
Union All
Select 641, 'Item Family', 200, '$All Item Family', 'QueryParams:[Values]:QueryParamID in (139) And [Values] Like ''%''', 0, '', null