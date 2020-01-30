CREATE VIEW V_SchemeDetail_bak    
([SchemeID], [StartValue], [EndValue], [FreeValue], [FreeItem], [FromIteminBaseUOM],    
[ToIteminBaseUOM], [FromIteminBaseUOM1], [ToIteminBaseUOM1], [FromIteminBaseUOM2],    
[ToIteminBaseUOM2],     
[StartQuantityinUOM],    
[StartQuantityinUOM1],    
[StartQuantityinUOM2],    
[EndQuantityinUOM],    
[EndQuantityinUOM1],    
[EndQuantityinUOM2],    
[FreeQuantityinUOM],    
[FreeQuantityinUOM1],    
[FreeQuantityinUOM2],      
[FreeUOM]     
)    
    
AS     
SELECT  SchemeItems.SchemeID, StartValue, EndValue, FreeValue, FreeItem  
,1 'FromIteminBaseUOM'  
,1 'ToIteminBaseUOM'  
,1 'FromIteminBaseUOM1'  
,1 'ToIteminBaseUOM1'  
,1 'FromIteminBaseUOM2'  
,1 'ToIteminBaseUOM2'  
,0 'StartQuantityinUOM'  
,0 'StartQuantityinUOM1'  
,0 'StartQuantityinUOM2'  
,0 'EndQuantityinUOM'  
,0 'EndQuantityinUOM1'  
,0 'EndQuantityinUOM2'  
,0 'FreeQuantityinUOM'  
,0 'FreeQuantityinUOM1'  
,0 'FreeQuantityinUOM2'  
,0 'FreeUOM'    
FROM  SchemeItems     
Inner Join Schemes On Schemes.SchemeType in (1, 2,  33, 34 , 65 )     
and Schemes.SchemeID = SchemeItems.SchemeID    
   
Union     
  
SELECT  SchemeItems.SchemeID, StartValue, EndValue, FreeValue, FreeItem  
,1 'FromIteminBaseUOM'  
,1 'ToIteminBaseUOM'  
,1 'FromIteminBaseUOM1'  
,1 'ToIteminBaseUOM1'  
,1 'FromIteminBaseUOM2'  
,1 'ToIteminBaseUOM2'  
,1 'StartQuantityinUOM'  
,1 'StartQuantityinUOM1'  
,1 'StartQuantityinUOM2'  
,1 'EndQuantityinUOM'  
,1 'EndQuantityinUOM1'  
,1 'EndQuantityinUOM2'  
,1 'FreeQuantityinUOM'  
,1 'FreeQuantityinUOM1'  
,1 'FreeQuantityinUOM2'  
,SchemeItems.FreeUOM 'FreeUOM'  
FROM  SchemeItems     
Inner Join Schemes On Schemes.SchemeType in (3,17, 18, 19, 20, 35 , 49, 50, 51, 52, 81, 82, 83 ,84 )     
AND Schemes.SchemeID = SchemeItems.SchemeID    
