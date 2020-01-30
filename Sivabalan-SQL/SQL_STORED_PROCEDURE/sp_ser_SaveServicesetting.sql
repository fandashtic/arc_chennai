CREATE procedure sp_ser_SaveServicesetting (@caption1 nvarchar(255),      
		@caption2 nvarchar(255),      
		@caption3 nvarchar(255),      
		@caption4 nvarchar(255),      
		@caption5 nvarchar(255))      
as      
declare @prevCaption1 nvarchar(255)
declare @prevCaption2 nvarchar(255)
declare @prevCaption3 nvarchar(255)
declare @prevCaption4 nvarchar(255)
select @prevCaption1 = ServiceCaption from ServiceSetting where ServiceCode = 'ItemSpec1'
select @prevCaption2 = Node from Reportdata where node = 'ItemSpec1 Wise Bounce Cases'

select @prevCaption3 = Node from Reportdata where node = 'Click to view itemspecwisebouncecases'

select @prevCaption4 = Node from Reportdata where node = 'ItemSpecI Wise Bounce Cases Detail'


if @caption1 = ''  set @caption1 = 'ItemSpec1'  
if @caption2 = ''  set @caption2 = 'ItemSpec2'  
if @caption3 = ''  set @caption3 = 'ItemSpec3'  
if @caption4 = ''  set @caption4 = 'ItemSpec4'  
if @caption5 = ''  set @caption5 = 'ItemSpec5'  
  
Update ServiceSetting Set ServiceCaption = @caption1, type = 0  where ServiceCode = 'ItemSpec1'   
Update ServiceSetting Set ServiceCaption = @caption2, type = 0  where ServiceCode = 'ItemSpec2'       
Update ServiceSetting Set ServiceCaption = @caption3, type = 0  where servicecode ='ItemSpec3'       
Update ServiceSetting Set ServiceCaption = @caption4, type = 0  where servicecode = 'ItemSpec4'           
Update ServiceSetting Set ServiceCaption = @caption5, type = 0  where servicecode = 'ItemSpec5'       
  
/* dynamic caption change */
update ParameterInfo set ParameterName = @Caption1, DefaultValue = '$All ' + @Caption1 
Where ParameterName = @prevCaption1 and DefaultValue = '$All ' + @prevCaption1 

/* dynamic caption changes in reportdata node */


update Reportdata set Node = @caption1  + space(1) + ' Wise Bounce Cases' where ID = 2088 --or Node = @prevCaption2
update Reportdata set [Description] = ' Click to view' +  @caption1  + ' wisebouncecases' where ID = 2088 --or [Description] = @prevCaption3
update Reportdata set [Description] = ' Click to view' + @caption1 + ' bouncecasedetail' where ID = 2089 --or Node =  @prevCaption4














