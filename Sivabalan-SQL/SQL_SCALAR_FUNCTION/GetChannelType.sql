
CREATE FUNCTION GetChannelType(@ChannelType int)
Returns nvarchar(128)
As
BEGIN
return dbo.LookupDictionaryItem(case IsNull(@ChannelType,0)            
when 1 then            
'BAKERY'            
when 2 then            
'BUNK'            
when 3 then            
'CHEMIST'            
when 4 then            
'CO-OPERATIVE'            
when 5 then            
'FANCY STORE'            
when 6 then            
'GENERAL MERCHANT'            
when 7 then            
'GROCER'            
when 8 then            
'SEMI WHOLESALER'            
when 9 then            
'SUPER MARKET'            
when 10 then            
'DEPARTMENTAL STORE'            
when 11 then
'Institution'
else            
'OTHERS'            
end,default)            
END


