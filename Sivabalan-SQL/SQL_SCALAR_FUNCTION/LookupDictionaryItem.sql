
CREATE FUNCTION LookupDictionaryItem(@DefaultValue nVarChar(4000), @Type VarChar(50) = 'LABEL')
RETURNS NVarChar(4000)
AS
BEGIN
DECLARE @LocalizedValue NVarChar(4000)  
If Exists(select * from master..sysdatabases where name = 'MLANG')  
Select @LocalizedValue = LocalizedValue From MLang..MLangResources   
Where LCID = (Select LocaleID From Setup) And ProjectID = 'FORUM' And DefaultValue = @DefaultValue   
And Type = @Type  
RETURN IsNull(@LocalizedValue, @DefaultValue)  
END

