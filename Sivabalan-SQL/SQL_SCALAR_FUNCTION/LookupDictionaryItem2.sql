
CREATE FUNCTION LookupDictionaryItem2(@LocalizedValue nVarChar(4000), @Type VarChar(50) = 'LABEL')
RETURNS NVarChar(4000)
AS
BEGIN
DECLARE @DefaultValue nVarChar(4000)  
If Exists(select * from master..sysdatabases where name = 'MLANG')  
Select @DefaultValue = DefaultValue From MLang..MLangResources   
Where LCID = (Select LocaleID From Setup) And ProjectID = 'FORUM' And LocalizedValue = @LocalizedValue   
And Type = @Type  
RETURN IsNull(@DefaultValue,@LocalizedValue)  
END

