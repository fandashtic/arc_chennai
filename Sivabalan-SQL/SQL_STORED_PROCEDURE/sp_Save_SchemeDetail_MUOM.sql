CREATE procedure sp_Save_SchemeDetail_MUOM
                (@SCHEMEID INT,  
                 @STARTVALUE Decimal(18,6),  
                 @ENDVALUE Decimal(18,6),  
                 @FREEVALUE Decimal(18,6),  
                 @FREEITEM NVARCHAR (255),  
                 @FromItem Decimal(18,6)=0,   
                 @ToItem Decimal(18,6)=0,
                 @PrimaryUOM Int = 0,
                 @FreeUOM Int = 0)  
As  
Insert SchemeItems  
                 (SchemeID,  
                  StartValue,  
                  EndValue,  
                  FreeValue,  
                  FreeItem,  
                  FromItem,   
                  ToItem,
                  PrimaryUOM,
                  FreeUOM)  
values  
                 (@SCHEMEID,  
                  @STARTVALUE,  
                  @ENDVALUE,  
                  @FREEVALUE,  
                  @FREEITEM,  
                  @FromItem,  
                  @ToItem,
                  @PrimaryUOM,
                  @FreeUOM)    
  
  
  
  


