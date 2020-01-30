

CREATE procedure sp_acc_prn_savedetail(@reportid int,@header nvarchar(255),
@footer nvarchar(255),@toplinebreak int,@bottomlinebreak int,@pagelength int,
@topmargin int,@bottommargin int,@printwidth int,@printtype int)
as
update FAReportData
set Header = @header,
    Footer = @footer,
    TopLineBreak = @toplinebreak,
    BottomLineBreak =  @bottomlinebreak,
    PageLength = @pagelength,
    TopMargin = @topmargin,
    BottomMargin = @bottommargin,
    PrintWidth = @printwidth,
    PrintType = @printtype
where ReportID = @reportid
    



    




