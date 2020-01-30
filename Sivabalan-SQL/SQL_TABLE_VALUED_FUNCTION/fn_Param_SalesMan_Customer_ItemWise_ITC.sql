CREATE Function fn_Param_SalesMan_Customer_ItemWise_ITC  
(  
   @CATEGORY_GROUP nVarchar(4000),    --1  
   @Hierarchy NVARCHAR(50),           --2  
   @CATEGORY NVARCHAR(4000),          --3  
   @UOM nVarChar(100),                --4  
   @DetailedAt nVarchar(50),          --5  
   @ItemwiseOnly nVarchar(50),        --6  
   @DSwise nVarchar(50),              --7  
   @Beat nVarchar(4000),              --8      
   @Customerwise nVarchar(50),        --9      
   @Datewise nVarchar(50),            --10    
   @FROMDATE nVarchar(50),            --11                  
   @TODATE nVarchar(50),              --12  
   @LevelOfReport nVarchar(50),       --13  
   @ParamRow  int                     --14  
)    
Returns @tmpQueryParams Table ([Values] NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)    
As    
Begin    
  
if @ItemwiseOnly = 'Yes'  
Begin  
     if @ParamRow = 7 or @ParamRow = 8  or @ParamRow = 9 or @ParamRow = 10  
     begin  
          Insert @tmpQueryParams   
          select 'N/A'  
     end  
End  
else if  @ItemwiseOnly = 'No'   
Begin  
    if @ParamRow = 7 --Avoid N/A  
    Begin  
         Insert @tmpQueryParams   
         select [Values] from QueryParams where queryparamid = 39 and [Values] not in ('N/A')  
    End  
    if @ParamRow = 8  
    Begin  
         if @DSwise = 'Summary' or @DSwise = 'N/A'  
            Insert @tmpQueryParams   
            select [Values] from QueryParams where queryparamid = 39 and [Values] in ('N/A')  
         if @DSwise = 'Detail'  
            Insert @tmpQueryParams   
            select [Values] from QueryParams where queryparamid = 39 and [Values] not in ('N/A')  
    End  
    if @ParamRow = 9  
    Begin  
         if @Beat = 'Summary' or @Beat = 'N/A'  
            Insert @tmpQueryParams   
            select [Values] from QueryParams where queryparamid = 39 and [Values] in ('N/A')  
         if @Beat = 'Detail'  
            Insert @tmpQueryParams   
            select [Values] from QueryParams where queryparamid = 39 and [Values] not in ('N/A')  
    End  
    if @ParamRow = 10  
    Begin  
         if @Customerwise = 'Summary' or @Customerwise = 'N/A'  
            Insert @tmpQueryParams   
            select [Values] from QueryParams where queryparamid = 39 and [Values] in ('N/A')  
         if @Customerwise = 'Detail'  
            Insert @tmpQueryParams   
            select [Values] from QueryParams where queryparamid = 39 and [Values] not in ('N/A')  
    End  
End  
  
Return    
End    

