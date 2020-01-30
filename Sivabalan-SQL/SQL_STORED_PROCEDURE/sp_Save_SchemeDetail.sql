CREATE procedure sp_Save_SchemeDetail
                (@SCHEMEID INT,
                 @STARTVALUE Decimal(18,6),
                 @ENDVALUE Decimal(18,6),
                 @FREEVALUE Decimal(18,6),
                 @FREEITEM NVARCHAR (255),
				 @FromItem Decimal(18,6)=0, 
				 @ToItem Decimal(18,6)=0)
As
Insert SchemeItems
                 (SchemeID,
                  StartValue,
                  EndValue,
                  FreeValue,
                  FreeItem,
				  FromItem, 
				  ToItem)
values
                 (@SCHEMEID,
                  @STARTVALUE,
                  @ENDVALUE,
                  @FREEVALUE,
                  @FREEITEM,
				  @FromItem,
				  @ToItem )  




