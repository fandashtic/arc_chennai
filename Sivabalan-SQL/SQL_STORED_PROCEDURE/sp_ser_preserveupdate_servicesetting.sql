CREATE Procedure sp_ser_preserveupdate_servicesetting  
as    
insert into ServiceSetting 
select * from TemplateDB.dbo.ServiceSetting 
where ServiceCode not in (select ServiceCode from ServiceSetting )
