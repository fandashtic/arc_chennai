using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace RetailApi.Models
{
    public partial class ForumDbContext : DbContext
    {
        public ForumDbContext()
        {
        }

        public ForumDbContext(DbContextOptions<ForumDbContext> options)
            : base(options)
        {
        }

        public virtual DbSet<AccountGroup> AccountGroup { get; set; }
        public virtual DbSet<AccountsMaster> AccountsMaster { get; set; }
        public virtual DbSet<AdjustmentReturnAbstractReceived> AdjustmentReturnAbstractReceived { get; set; }
        public virtual DbSet<Apvabstract> Apvabstract { get; set; }
        public virtual DbSet<Areas> Areas { get; set; }
        public virtual DbSet<Bank> Bank { get; set; }
        public virtual DbSet<BankAccountPaymentModes> BankAccountPaymentModes { get; set; }
        public virtual DbSet<BankMaster> BankMaster { get; set; }
        public virtual DbSet<BatchProducts> BatchProducts { get; set; }
        public virtual DbSet<Beat> Beat { get; set; }
        public virtual DbSet<BillAbstract> BillAbstract { get; set; }
        public virtual DbSet<BranchMaster> BranchMaster { get; set; }
        public virtual DbSet<Brand> Brand { get; set; }
        public virtual DbSet<BusinessNature> BusinessNature { get; set; }
        public virtual DbSet<CashCustomerRec> CashCustomerRec { get; set; }
        public virtual DbSet<CatalogAbstract> CatalogAbstract { get; set; }
        public virtual DbSet<City> City { get; set; }
        public virtual DbSet<ClaimsNote> ClaimsNote { get; set; }
        public virtual DbSet<ClientInformation> ClientInformation { get; set; }
        public virtual DbSet<CollectionsReceived> CollectionsReceived { get; set; }
        public virtual DbSet<Comversion> Comversion { get; set; }
        public virtual DbSet<ConversionTable> ConversionTable { get; set; }
        public virtual DbSet<Country> Country { get; set; }
        public virtual DbSet<CreditNote> CreditNote { get; set; }
        public virtual DbSet<CreditTerm> CreditTerm { get; set; }
        public virtual DbSet<Customer> Customer { get; set; }
        public virtual DbSet<CustomerCategory> CustomerCategory { get; set; }
        public virtual DbSet<CustomerChannel> CustomerChannel { get; set; }
        public virtual DbSet<CustomerHierarchy> CustomerHierarchy { get; set; }
        public virtual DbSet<CustomerSegment> CustomerSegment { get; set; }
        public virtual DbSet<DebitNote> DebitNote { get; set; }
        public virtual DbSet<Deposits> Deposits { get; set; }
        public virtual DbSet<Disclaimer> Disclaimer { get; set; }
        public virtual DbSet<DispatchAbstract> DispatchAbstract { get; set; }
        public virtual DbSet<Doctor> Doctor { get; set; }
        public virtual DbSet<DocumentNumbers> DocumentNumbers { get; set; }
        public virtual DbSet<FormatInfo> FormatInfo { get; set; }
        public virtual DbSet<Grnabstract> Grnabstract { get; set; }
        public virtual DbSet<Groups> Groups { get; set; }
        public virtual DbSet<Gstcomponent> Gstcomponent { get; set; }
        public virtual DbSet<InvoiceAbstract> InvoiceAbstract { get; set; }
        public virtual DbSet<InvoiceAbstractReceived> InvoiceAbstractReceived { get; set; }
        public virtual DbSet<ItemCategories> ItemCategories { get; set; }
        public virtual DbSet<Itemhierarchy> Itemhierarchy { get; set; }
        public virtual DbSet<Items> Items { get; set; }
        public virtual DbSet<ItemSchemes> ItemSchemes { get; set; }
        public virtual DbSet<Manufacturer> Manufacturer { get; set; }
        public virtual DbSet<Poabstract> Poabstract { get; set; }
        public virtual DbSet<PoabstractReceived> PoabstractReceived { get; set; }
        public virtual DbSet<ProductCategorization> ProductCategorization { get; set; }
        public virtual DbSet<Properties> Properties { get; set; }
        public virtual DbSet<QueryFields> QueryFields { get; set; }
        public virtual DbSet<QueryParams2> QueryParams2 { get; set; }
        public virtual DbSet<QueryTables> QueryTables { get; set; }
        public virtual DbSet<QuotationAbstract> QuotationAbstract { get; set; }
        public virtual DbSet<ReceivedCustomers> ReceivedCustomers { get; set; }
        public virtual DbSet<ReceivedSegments> ReceivedSegments { get; set; }
        public virtual DbSet<RejectionReason> RejectionReason { get; set; }
        public virtual DbSet<ReportData> ReportData { get; set; }
        public virtual DbSet<Reports> Reports { get; set; }
        public virtual DbSet<ReportsToUpload> ReportsToUpload { get; set; }
        public virtual DbSet<Salesman> Salesman { get; set; }
        public virtual DbSet<SalesPortalIplist> SalesPortalIplist { get; set; }
        public virtual DbSet<Salesstaff> Salesstaff { get; set; }
        public virtual DbSet<Schemes> Schemes { get; set; }
        public virtual DbSet<SchemesRec> SchemesRec { get; set; }
        public virtual DbSet<ServiceTypeMaster> ServiceTypeMaster { get; set; }
        public virtual DbSet<Soabstract> Soabstract { get; set; }
        public virtual DbSet<SoabstractReceived> SoabstractReceived { get; set; }
        public virtual DbSet<SoldAs> SoldAs { get; set; }
        public virtual DbSet<SpecialCategory> SpecialCategory { get; set; }
        public virtual DbSet<State> State { get; set; }
        public virtual DbSet<StateCode> StateCode { get; set; }
        public virtual DbSet<StockAdjustmentReason> StockAdjustmentReason { get; set; }
        public virtual DbSet<StockRequestAbstractReceived> StockRequestAbstractReceived { get; set; }
        public virtual DbSet<StockTransferInAbstract> StockTransferInAbstract { get; set; }
        public virtual DbSet<StockTransferOutAbstract> StockTransferOutAbstract { get; set; }
        public virtual DbSet<StockTransferOutAbstractReceived> StockTransferOutAbstractReceived { get; set; }
        public virtual DbSet<TargetMeasure> TargetMeasure { get; set; }
        public virtual DbSet<TargetPeriod> TargetPeriod { get; set; }
        public virtual DbSet<Tax> Tax { get; set; }
        public virtual DbSet<TaxApplicableOn> TaxApplicableOn { get; set; }
        public virtual DbSet<TaxStateType> TaxStateType { get; set; }
        public virtual DbSet<TblMErpAlltaxtype> TblMErpAlltaxtype { get; set; }
        public virtual DbSet<TblMErpConfigAbstract> TblMErpConfigAbstract { get; set; }
        public virtual DbSet<TblMerpSurveyChannelMapping> TblMerpSurveyChannelMapping { get; set; }
        public virtual DbSet<TblMerpSurveyDsmapping> TblMerpSurveyDsmapping { get; set; }
        public virtual DbSet<TblMerpSurveyMaster> TblMerpSurveyMaster { get; set; }
        public virtual DbSet<TblMerpSurveyProductMapping> TblMerpSurveyProductMapping { get; set; }
        public virtual DbSet<TblMerpSurveyQuestionAnswerMapping> TblMerpSurveyQuestionAnswerMapping { get; set; }
        public virtual DbSet<TblMerpSurveyQuestionMapping> TblMerpSurveyQuestionMapping { get; set; }
        public virtual DbSet<TblMErpZone> TblMErpZone { get; set; }
        public virtual DbSet<Uom> Uom { get; set; }
        public virtual DbSet<UpgradeTables> UpgradeTables { get; set; }
        public virtual DbSet<Users> Users { get; set; }
        public virtual DbSet<Van> Van { get; set; }
        public virtual DbSet<VanStatementAbstract> VanStatementAbstract { get; set; }
        public virtual DbSet<VanStatementDetail> VanStatementDetail { get; set; }
        public virtual DbSet<Vendors> Vendors { get; set; }
        public virtual DbSet<VoucherPrefix> VoucherPrefix { get; set; }
        public virtual DbSet<WareHouse> WareHouse { get; set; }

        // Unable to generate entity type for table 'dbo.Reports_to_Resend'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.APVDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ColorSettings'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RedemptionAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Reports_to_upload_B4STDBK'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TradeCustomerCategory'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RedemptionDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GSTBillTaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReportParameters_Upload_B4STDBK'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PrintSpecs_Exception'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Occupation'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PRTaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AdjustmentReturnAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_OtherReportsUpload_B4STDBK'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_CSOutletPointAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PODetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Awareness'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GSTSTOTaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_VoucherResetYearly'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DynamicProcedure_16042018'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.MarketInfo'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PODetailReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AccountOpeningBalance'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GSTSTITaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GSTDocumentNumbers'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PriceChangeDetails'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblConfig_EffectFrom'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.XMLColumnMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.BankClosingBalance'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PricingAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.XMLDataMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_CSOutletPointDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.QuotationItems'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Batch_Assets'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_Paramvalues'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DandDTaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DandDInvAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PricingSegmentDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Special_Cat_Product'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblInstallationDetail_Bk'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.QuotationMfrCategory'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ContraAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.MailMessage'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PricingPaymentDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.StockDesturct_DC'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblDependentDetail_Bk'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.QuotationUniversal'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ContraDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AdjustmentReturnDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SentInvoices'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PaymentTerm'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_DayCloseLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Denominations'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AdjustmentReturnDetail_Received'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DandDInvDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.FAHeaderPrintsetting'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.auditmaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PointsCustomer'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReconcileDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DandDLegend'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SellingDays'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PasswordLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.FAPrintSetting'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GRN_Combo_Components'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_ReconcileBatchReason'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SalesmanTarget'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.InvoiceDetailReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdTaxBeforeDiscount'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PSDCProgressStatus'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.FAUpgradeStatus'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.InvoiceTaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PricingSegmentDetailReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.QuotationCustomers'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_DSOSTransfer'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Invoice_Combo_Components'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_TaxBeforeDiscount'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PricingPaymentDetailReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SchemeCustomerItems'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ManualJournal'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Dispatch_Combo_Components'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_versionupgrade_611'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AdjustmentReason'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.VirtualOrders_Master'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DBScript'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ConsolidateAccount'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.EditMarginLock'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SubChannel'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SchemeItems'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ConsolidateAccountGroup'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DrillDownPrintSpecs'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSRouteInfo'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReceiveAccount'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.VajraBatchFiles'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Customer_Backup_11Jan2020'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReceiveAccountGroup'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_CustActiveDeactive'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SOimportFlag'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ChequeCollDetails'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Companies_To_Upload'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SchemeItems_REC'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.HeadWiseInfo'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.MarginAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.District'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.BatchFileLogs'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.MarginDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.HeadWiseInfo_Received'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.STITaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_CatHandler_Log'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.QuotationMfrCategory_LeafLevel'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ErrorMessages'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DandDAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Setup'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdDoc_DSTypeCGCategoryMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SYS_DE_LOG'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ImportTemplates'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.BillDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DandDCategory'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PMetric_TargetDefn_Backup_25_Feb_2020'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.FSUFileAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_DSTypeCGCategoryMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Scheme_Details'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SchemeSale'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.STOTaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Cash_Customer'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdChannlAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Batch_Products_Copy'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RestrictedOLClass'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.FSUFileDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.BillTaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdChannlDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.VanStatementAbstract_Copy'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_DamagesRFAPrint'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Bill_Combo_Components'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSTypeCGCategoryMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CategoryExceptional'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.VanStatementDetail_Copy'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DandDDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdCatAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Customer_Type_Log'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_OCG_DSTypeCategoryMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdCatDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.InvoiceDiscountReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.temp_invoicedetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdDoc_PMOLT'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_UploadReportTracker'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.QueryParams1'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ItemsRecUpdateStatus'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AssetMaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TmpPM'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.temp_vanstatementdetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RestrictedIniFiles'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReportAbstractReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_QPSGenProcessLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TmpPMDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.temp_adjustmentreturndetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_PMOLT'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_UploadReportXMLTracker'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReportDetailReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.OCG_DSTypeCategoryMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AssetInfoTracking_HH'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdMstChangeAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TmpPMGroups'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.temp_stockadjustment'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.StockDestructionAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SyncError'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ClaimsDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdMstChangeDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.temp_stocktransferindetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SalesmanCategory'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PMOutlet'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ClaimsDetailReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TmpPMRepost_TLCNOA'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSTypeWiseSKU'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PTRMargin'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdCatHandAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeApplicableType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.temp_stocktransferoutdetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdTLTypeAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SODetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdDoc_PMOutletAchieve'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.def_beat'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AssetAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdCatHandDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeItemGroup'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.temp_vantransferdetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdRptAckAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SetupDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PatchDetails'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TmpDSTypeCategoryMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeSlabType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.temp_sodetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DepositsDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdTLTypeDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SODetailReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_PMOutletAchieve'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSTYPE_IMAGE'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AssetDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_QPSAbsData'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AutoAdjExcludeDSType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdErrMessages'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_GrandTotExceptionalRpts'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tmpDSPMSalesman'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.temp_batch_products'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TmpPMRepost'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdRptAckDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustomerLedger'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_Clientfileinfo'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TmpNewCustomers'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Shortcuts'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Stock_Request_Abstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PMOutletAchieve'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdDoc_Asset'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Tmp_SKUOPT_DailySKU'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_ProdMargin_AuditLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PricingAbstractReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustomerCreditLimit_Backup_18_Feb_2020'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ClaimsNoteReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AssetDetailReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Output_SD_OutletFlag_ProdDtl'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Tmp_VInvoice'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_QPSCrNoteLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_PMOutletAch_TargetDefn'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdSchMinQty'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.HHViewLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.InvoiceDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CollectionDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SchMinQty'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.XMLSplitup'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_ConfigDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_Recd_PMMaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CollectionDetailReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Stock_Request_Detail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Collections'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_OLClassMapping'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Stock_Request_Detail_Received'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DeliveryDetails'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_Margin_Log'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SchemeProducts'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.StockAdjustment'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_Recd_PMDSType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.StockAdjustmentAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_NOA_TargetDefn'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_QPSDtlData'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecConfigAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CategoryGroups'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_AEActivity'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_ProcessStatus'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.InvoiceReportCustomer_Mapping'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SchemeProducts_log'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TaxComponentDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tmpInvoiceAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecConfigDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ConversionDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblReleaseDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_Recd_PMParam'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CatalogDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.StockDestructionDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdDSTrainingAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Category'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_AEAuditLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReportParameters_Upload'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_TradeSchemeRFAPrint'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_Recd_PMParamFocus'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_AELoginInfo'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.temp_Update_SchemeProducts'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Combo_Components'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_DisplaySchemeRFAPrint'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdDSTrainingDetails'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblUpdateDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ItemFamily'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_AEModule'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PointsSchemeRFAPrint'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ParameterInfo'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_Recd_PMParamSlab'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.HH_TRACEROUTE_GPS'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.HandHeldCollProcessLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.StockTransferInDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TallyTaxDetails'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_DSTraining'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ItemSubFamily'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.HandHeldCollProcessTrace'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PrintSpecs'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RFADet_Reason'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.InvFromSODetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DayCloseTracker'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_BackDtSchProcessInfo'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CategoryPropReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblDocumentDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DayCloseModules'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LP_RecdDocAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CategoryPropertyReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.OLTargetAchievement'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ItemGroup'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Config_DataPurging'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CategoryReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.NewCustomer_HH'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PMMaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_DSTrainingDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ItemPropReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RebateRate'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LP_RecdScoreDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GGRR_AuditTrail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.HHCustomer'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblClientMaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Product_Mappings'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PM_DS_Data'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ValidateDataPurging'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_Merp_RFAXmlStatus'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LP_RecdCodeMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.StockTransferOutDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GGRRProdFinal'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ItemsReceivedAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CatalogNotification'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LP_RecdAchievementDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.StockTransferOutDetailReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PMDSType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LP_ScoreDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Beat_Salesman'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdRFAckAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Test1'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_Display_SchCategory'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_Cust_HHReasonMaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Special_Category_Rec'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblMessageDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_OCG'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TransactionDocNumber'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.QueryParams'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CrNoteDSType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PMParam'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Printing1'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdRFAckDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LP_ItemCodeMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GGRRFinalData'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_DSType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.StockMovementMonthly'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.VAllocAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SupervisorType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RFASubmission_Reason'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Special_Cat_Product_Rec'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TransactionByDay'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReportNarration'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RFAAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TransactionType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DispatchDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.BounceNote'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PMParamFocus'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.FavoriteReports'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdOLClassAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RFADetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DocumentUsers'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LP_AchievementDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_NonQPSData'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DownloadedItems'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SupervisorSalesman'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.BillDiscountMaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblErrorLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_OCGName'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdMarginAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ConversionAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SACMasterByFSU'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.BillDiscount'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PMParamSlab'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.VoucherReset'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_SKUPortfolio'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdOLClassDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.InvoiceReasons'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.VAllocDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_VersionUpgrade_BK'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ItemSchemes_Rec'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdMarginDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LPCustomerScore'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.VanTransferDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PendingGGRRFinalDataPost'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.VehicleAllocationVan'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_VersionUpgrade_BK25062018'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_OCG_DSType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_WDSKUList'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdDSTypeCGAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdQuotationAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReceivedMail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ProductCategoryGroupAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SplCatSchemes'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblInstallationDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PMetric_TargetDefn'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReasonMaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_OtherReportsUpload'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LPPrintconfig'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_CRDropPayoutActive'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_CategorywiseSOQ'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Customer_audit'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SKUPortfolio'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdDSTypeCGDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdSchAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GT_Invoice'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdQuotationDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LPLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ForeCast'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_OCG_Product'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_CGCustomer'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSFailVisitReasons'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ProductCategoryGroupDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_GGDR'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_DynamicParameterDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblConfigDC'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdSchProductScope'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdReasonAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustomerGPSPosition'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustomerProductCategory'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GRNDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TLCAchievement'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_UploadParam_Exception'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblInstalledVersions'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.WDSKUList'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdAELoginAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdSchChannel'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_QuotChannelDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LPDisclaimer'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_GGDROutlet'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PMFrequency'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.OCG_Product'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.printspecs1'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdSchOutletClass'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdReasonDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CategoryLevelInfo'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_NOA_TargetDefn_Detail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdSchOutlet'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_MarginAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustomerCreditLimit'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_RecdItemCodeRestricted'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdAELoginDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdSchSlabDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PM_GateUOB_MonthlyData'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_MarginDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DayCloseLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblFSUSetUp'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PMParamType'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.OCGItemMaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_SKUOpt_Monthly'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_VersionUpgrade'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblDependentDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_ItemCodeRestricted'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PrintingHistory'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_SKUOPT_int'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdCGDefnAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_GGDRProduct'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DynamicProcedure'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PMGivenAs'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_SKUOpt_Incremental'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdCGDefnDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ForeCast_Abstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeChannel'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.OrderAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.HMSKU'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeOutletClass'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ClaimSchemes'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.del_Table_List'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeOutlet'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PriceList'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.OrderDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PrintCoordinates'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PointsSchemeReversal'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_PMUOM'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Merchandise'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeSlabDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PriceListBranch'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSHandle'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeFreeSKU'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PriceListItem'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustMerchandise'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeProductScopeMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.BranchState'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SendPriceList'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ARVDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReportData_Salem'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Loyalty'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Cust_TMD_Master'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Order_Header'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchCategoryScope'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReportUploadAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SendPriceListBranch'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GGDROutlet'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ARVAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.QueryParams_SALEM'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchSubCategoryScope'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReportUploadDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SendPriceListItem'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_CLOCreditPrint'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdSchLoyaltyList'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GeneralJournal'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ParameterInfo_Salem'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Cust_TMD_Details'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchMarketSKUScope'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReportUploadMsg'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReceivePriceListAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeLoyaltyList'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tempCatList1'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchSKUCodeScope'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.FilesUpload'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tempCatList2'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_DSTypeCGMapping'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReceivePriceListTaxDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Cheques'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Order_Header_Copy'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReceivePriceListItemDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Category_Properties'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GGDRProduct'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdChannelMarginDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_OLClass'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DS_TimeSpent'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustomerCheques'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.NoteDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Dump_Report_Config'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ItemClosingStock'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeSale'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Item_Properties'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.FAReportData'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReconcileAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_ChannelMarginDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Fail_Visit_Reason'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Order_Details'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_Taxtype'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_SalesPortalIP'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.BatchWiseChannelPTR'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Inbound_Status'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TmpGGDRSKUDetails'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.HH_Collection'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Product_Focus'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.StockOutAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GGDRData'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_ChannelMargin_AuditLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Order_Details_Copy'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.StockOutDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_Tax'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SchemeCustomers'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Product_Launch'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ItemsReceivedDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_CatGrpDiv_Master'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Customer_Mappings'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_TaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Collection_Details'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CLOCrNote'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_ItemTaxMapping'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdDispSchCapPerOutlet'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DS_SOH_HDR'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Customer_CategoryGroups'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Collection_Details_copy'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.OpeningDetails'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.QueryParams3'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GGRRDayCloseLog'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemePayoutPeriod'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CampaignMaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SRAbstractReceived'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GiftVoucher'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CampaignCustomers'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_TransactionIni'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdDoc_CLOCrNote'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SavedQueries'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DS_SOH_DTL'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Customer_Groups'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Stock_Return'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PaymentExpense'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GiftVoucherDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustomerObjective'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Scheme_Details_Copy'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PaymentDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.InvoiceWiseCollectionAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.JournalDenominations'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.IssueGiftVoucher'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.VanTransferAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblConfigPAN'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SalesmanScopeDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_CLOCrNote'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.paymentmode'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.InvoiceWiseCollectionDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SchemeCustomers_Rec'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_DispSchBudgetPayout'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ScopeMaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Payments'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DefaultFAPrintSetting'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.WcpAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSTypePlanning'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ImplicitConfig'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_CLOSchemeRFAPrint'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Salesman2'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdDoc_LaunchItems'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TracePTaxMap4Item'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.WCPDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Inbound_Log'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GiftVoucherRedeemIDS'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TraceSTaxMap4Item'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CampaignDrives'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_RecdMerchandise'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Stock_Return_Copy'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_LaunchItems'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ItemsSTaxMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSSurveyDetails'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_DispSchCapPerOutlet'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SVAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ServiceAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Collection_Action'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_SchemeSubGroup'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SVDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_RecdCustomerwiseMerchandise'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSType_Master'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.LaunchItems'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Salutation'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ItemsPTaxMap'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ExciseTax'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblTools'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_RecdDocAck'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.OutletGeo'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustomerSalesSummaryAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_CSRedemption'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSType_Details'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.OutletGeo_staging'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_StateMasterAbs'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ServiceDetails'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SpecialSKUMaster_Received'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustomerMarketInfo'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ValidateItemDeactivation'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustomerSalesSummaryDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_StateMasterDet'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ExciseTaxComponentDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReportParameters'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tblCGDivMapping'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ServiceInvoicesTaxSplitup'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSType_master_tmp'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Coupon'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdDoc_StateCode'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ExciseTaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PM_GateUOB_Data'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GiftVoucherOthers'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SRVINV_PrintFormat'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SpecialSKUMaster'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdMarketInfoAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RetailPaymentDetails'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_WDStateCode'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_OutletPoints'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_merp_fileinfo'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.DSTypeLabel'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PointsAbstract'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ReportFormula'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RetailCustomerCategory'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.CustomPrinting'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.SpecialSKUAccounts'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.TrackCustomerPoint'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.PointsDetail'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.GSTInvoiceTaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AdjClaimReference'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.tbl_mERP_OutletPoints_NonQPS'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Redemption'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.Recd_InvoiceTaxComponents'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.AdjustmentReference'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.ParameterInfo_B4STDBK'. Please see the warning messages.
        // Unable to generate entity type for table 'dbo.RecdMarketInfoDetail'. Please see the warning messages.

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer("Server=.;Database=Minerva_ARC001_2019;UID=sa;PWD=athena;");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<AccountGroup>(entity =>
            {
                entity.HasKey(e => e.GroupId);

                entity.HasIndex(e => e.GroupName)
                    .HasName("IX_AccountGroup");

                entity.Property(e => e.GroupId).HasColumnName("GroupID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.GroupName)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.LastModifiedDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");
            });

            modelBuilder.Entity<AccountsMaster>(entity =>
            {
                entity.HasKey(e => e.AccountId);

                entity.HasIndex(e => e.AccountName)
                    .HasName("IX_AccountsMaster");

                entity.Property(e => e.AccountId).HasColumnName("AccountID");

                entity.Property(e => e.AccountName).HasMaxLength(255);

                entity.Property(e => e.AdditionalField10).HasMaxLength(30);

                entity.Property(e => e.AdditionalField11).HasMaxLength(30);

                entity.Property(e => e.AdditionalField12).HasMaxLength(30);

                entity.Property(e => e.AdditionalField13).HasMaxLength(30);

                entity.Property(e => e.AdditionalField14).HasMaxLength(30);

                entity.Property(e => e.AdditionalField15)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.AdditionalField16)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.AdditionalField17)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.AdditionalField4).HasColumnType("datetime");

                entity.Property(e => e.AdditionalField5).HasColumnType("datetime");

                entity.Property(e => e.AdditionalField6).HasMaxLength(30);

                entity.Property(e => e.AdditionalField7).HasMaxLength(100);

                entity.Property(e => e.AdditionalField8).HasMaxLength(30);

                entity.Property(e => e.AdditionalField9).HasMaxLength(30);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DefaultGroupId).HasColumnName("DefaultGroupID");

                entity.Property(e => e.GroupId).HasColumnName("GroupID");

                entity.Property(e => e.LastModifiedDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.UserName).HasMaxLength(50);
            });

            modelBuilder.Entity<AdjustmentReturnAbstractReceived>(entity =>
            {
                entity.HasKey(e => e.AdjustmentId);

                entity.ToTable("AdjustmentReturnAbstract_Received");

                entity.Property(e => e.AdjustmentId).HasColumnName("AdjustmentID");

                entity.Property(e => e.AdjustmentDate).HasColumnType("datetime");

                entity.Property(e => e.Balance).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.BillId)
                    .HasColumnName("BillID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.CreationTime)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.ForumId).HasMaxLength(50);

                entity.Property(e => e.Value).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.VendorId)
                    .IsRequired()
                    .HasColumnName("VendorID")
                    .HasMaxLength(15);
            });

            modelBuilder.Entity<Apvabstract>(entity =>
            {
                entity.HasKey(e => e.DocumentId);

                entity.ToTable("APVAbstract");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.AmountApproved).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Apvdate)
                    .HasColumnName("APVDate")
                    .HasColumnType("datetime");

                entity.Property(e => e.Apvid).HasColumnName("APVID");

                entity.Property(e => e.Apvremarks)
                    .HasColumnName("APVRemarks")
                    .HasMaxLength(4000);

                entity.Property(e => e.Balance).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.BillAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.BillDate).HasColumnType("datetime");

                entity.Property(e => e.BillNo).HasMaxLength(50);

                entity.Property(e => e.CancellationRemarks).HasMaxLength(4000);

                entity.Property(e => e.CreationTime).HasColumnType("datetime");

                entity.Property(e => e.DocSerialType).HasMaxLength(100);

                entity.Property(e => e.DocumentReference).HasMaxLength(255);

                entity.Property(e => e.OtherAccountId).HasColumnName("OtherAccountID");

                entity.Property(e => e.OtherValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.PartyAccountId).HasColumnName("PartyAccountID");

                entity.Property(e => e.RefDocId).HasColumnName("RefDocID");
            });

            modelBuilder.Entity<Areas>(entity =>
            {
                entity.HasKey(e => e.AreaId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.Area)
                    .HasName("IX_Areas")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.AreaId).HasColumnName("AreaID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.Area)
                    .IsRequired()
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<Bank>(entity =>
            {
                entity.HasKey(e => new { e.AccountNumber, e.BankCode });

                entity.HasIndex(e => e.BankName)
                    .HasName("IX_Bank");

                entity.Property(e => e.AccountNumber)
                    .HasColumnName("Account_Number")
                    .HasMaxLength(64);

                entity.Property(e => e.BankCode).HasMaxLength(50);

                entity.Property(e => e.AccountId).HasColumnName("AccountID");

                entity.Property(e => e.AccountName)
                    .HasColumnName("Account_Name")
                    .HasMaxLength(128);

                entity.Property(e => e.BankId)
                    .HasColumnName("BankID")
                    .ValueGeneratedOnAdd();

                entity.Property(e => e.BankName)
                    .HasColumnName("Bank_Name")
                    .HasMaxLength(128);

                entity.Property(e => e.Branch).HasMaxLength(128);

                entity.Property(e => e.BranchCode).HasMaxLength(50);

                entity.Property(e => e.ClientId).HasColumnName("Client_ID");

                entity.Property(e => e.OriginalId).HasColumnName("OriginalID");

                entity.Property(e => e.ServiceChargePercentage).HasColumnType("decimal(18, 6)");
            });

            modelBuilder.Entity<BankAccountPaymentModes>(entity =>
            {
                entity.HasKey(e => new { e.BankId, e.CreditCardId });

                entity.ToTable("BankAccount_PaymentModes");

                entity.Property(e => e.BankId).HasColumnName("BankID");

                entity.Property(e => e.CreditCardId).HasColumnName("CreditCardID");

                entity.Property(e => e.ServiceChargePercentage).HasColumnType("decimal(18, 6)");
            });

            modelBuilder.Entity<BankMaster>(entity =>
            {
                entity.HasKey(e => e.BankCode);

                entity.HasIndex(e => e.BankName)
                    .HasName("IX_BankMaster")
                    .IsUnique();

                entity.Property(e => e.BankCode)
                    .HasMaxLength(10)
                    .ValueGeneratedNever();

                entity.Property(e => e.BankName)
                    .IsRequired()
                    .HasMaxLength(128);
            });

            modelBuilder.Entity<BatchProducts>(entity =>
            {
                entity.HasKey(e => e.BatchCode)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("Batch_Products");

                entity.Property(e => e.BatchCode).HasColumnName("Batch_Code");

                entity.Property(e => e.BatchNumber)
                    .HasColumnName("Batch_Number")
                    .HasMaxLength(128);

                entity.Property(e => e.ClaimedAlready).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ClientId).HasColumnName("Client_ID");

                entity.Property(e => e.ComboId).HasColumnName("ComboID");

                entity.Property(e => e.CompanyPrice)
                    .HasColumnName("Company_Price")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DocDate).HasColumnType("datetime");

                entity.Property(e => e.DocId).HasColumnName("DocID");

                entity.Property(e => e.Ecp)
                    .HasColumnName("ECP")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ExciseDuty).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ExciseId)
                    .HasColumnName("ExciseID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.Expiry).HasColumnType("datetime");

                entity.Property(e => e.GrnId).HasColumnName("GRN_ID");

                entity.Property(e => e.GrnapplicableOn).HasColumnName("GRNApplicableOn");

                entity.Property(e => e.GrnpartOff)
                    .HasColumnName("GRNPartOff")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.GrntaxId).HasColumnName("GRNTaxID");

                entity.Property(e => e.GrntaxSuffered)
                    .HasColumnName("GRNTaxSuffered")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.GsttaxType).HasColumnName("GSTTaxType");

                entity.Property(e => e.MarginAddOn).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.MarginDetId).HasColumnName("MarginDetID");

                entity.Property(e => e.MarginOn).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.MarginPerc).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.MrpforTax)
                    .HasColumnName("MRPforTax")
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("((0))");

                entity.Property(e => e.MrpperPack)
                    .HasColumnName("MRPPerPack")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.OrgPts)
                    .HasColumnName("OrgPTS")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Partofpercentage).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Pfm)
                    .HasColumnName("PFM")
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("((0))");

                entity.Property(e => e.Pkd)
                    .HasColumnName("PKD")
                    .HasColumnType("datetime");

                entity.Property(e => e.ProductCode)
                    .HasColumnName("Product_Code")
                    .HasMaxLength(50);

                entity.Property(e => e.Promotion).HasDefaultValueSql("(0)");

                entity.Property(e => e.Ptr)
                    .HasColumnName("PTR")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Pts)
                    .HasColumnName("PTS")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.PurchasePrice)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.PurchaseTax).HasDefaultValueSql("(0)");

                entity.Property(e => e.Quantity)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.QuantityReceived).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ReceInvItemOrder).HasDefaultValueSql("(null)");

                entity.Property(e => e.SalePrice)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.Serial).HasDefaultValueSql("(0)");

                entity.Property(e => e.StockReconId).HasColumnName("StockReconID");

                entity.Property(e => e.StockTransferId).HasColumnName("StockTransferID");

                entity.Property(e => e.TaxOnMrp).HasColumnName("TaxOnMRP");

                entity.Property(e => e.TaxSuffered).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Toq)
                    .HasColumnName("TOQ")
                    .HasDefaultValueSql("((0))");

                entity.Property(e => e.Uom).HasColumnName("UOM");

                entity.Property(e => e.Uomprice)
                    .HasColumnName("UOMPrice")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Uomqty)
                    .HasColumnName("UOMQty")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.VatLocality).HasColumnName("Vat_Locality");
            });

            modelBuilder.Entity<Beat>(entity =>
            {
                entity.HasKey(e => e.BeatId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.Description)
                    .HasName("IX_Beat")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.BeatId).HasColumnName("BeatID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Description)
                    .IsRequired()
                    .HasMaxLength(255);
            });

            modelBuilder.Entity<BillAbstract>(entity =>
            {
                entity.HasKey(e => e.BillId)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.BillId).HasColumnName("BillID");

                entity.Property(e => e.AddlDiscountAmount)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.AddlDiscountPercentage)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.AdjRef).HasMaxLength(255);

                entity.Property(e => e.AdjustedAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.AdjustmentAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.AdjustmentValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Balance).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.BillDate).HasColumnType("datetime");

                entity.Property(e => e.CancelDate).HasColumnType("datetime");

                entity.Property(e => e.CancelUserName).HasMaxLength(50);

                entity.Property(e => e.ClientId).HasColumnName("ClientID");

                entity.Property(e => e.CreationTime).HasColumnType("datetime");

                entity.Property(e => e.Discount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.DiscountBeforeExcise).HasDefaultValueSql("(0)");

                entity.Property(e => e.DocIdreference)
                    .HasColumnName("DocIDReference")
                    .HasMaxLength(510);

                entity.Property(e => e.DocSerialType).HasMaxLength(100);

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.ExciseDuty).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.FapaymentId).HasColumnName("FAPaymentID");

                entity.Property(e => e.Freight)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.Grnid)
                    .HasColumnName("GRNID")
                    .HasMaxLength(255);

                entity.Property(e => e.GstenableFlag).HasColumnName("GSTEnableFlag");

                entity.Property(e => e.Gstflag).HasColumnName("GSTFlag");

                entity.Property(e => e.Gstin)
                    .HasColumnName("GSTIN")
                    .HasMaxLength(15);

                entity.Property(e => e.InvoiceReference).HasMaxLength(50);

                entity.Property(e => e.NewGrnid)
                    .HasColumnName("NewGRNID")
                    .HasMaxLength(255);

                entity.Property(e => e.OctroiAmount)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.Odnumber)
                    .HasColumnName("ODNumber")
                    .HasMaxLength(50);

                entity.Property(e => e.PaymentDate).HasColumnType("datetime");

                entity.Property(e => e.PaymentId).HasColumnName("PaymentID");

                entity.Property(e => e.ProductDiscount)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.PurchasePriceBeforeExcise).HasDefaultValueSql("(0)");

                entity.Property(e => e.Remarks).HasMaxLength(2000);

                entity.Property(e => e.Surcharge)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.TaxAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.TaxOnMrp).HasColumnName("TaxOnMRP");

                entity.Property(e => e.Username).HasMaxLength(50);

                entity.Property(e => e.Value).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.VattaxAmount)
                    .HasColumnName("VATTaxAmount")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.VendorId)
                    .HasColumnName("VendorID")
                    .HasMaxLength(15);
            });

            modelBuilder.Entity<BranchMaster>(entity =>
            {
                entity.HasKey(e => new { e.BranchCode, e.BankCode });

                entity.Property(e => e.BranchCode).HasMaxLength(10);

                entity.Property(e => e.BankCode).HasMaxLength(10);

                entity.Property(e => e.BranchName)
                    .IsRequired()
                    .HasMaxLength(128);
            });

            modelBuilder.Entity<Brand>(entity =>
            {
                entity.HasKey(e => e.BrandId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.BrandName)
                    .HasName("IX_Brand")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.BrandId).HasColumnName("BrandID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.BrandName)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.ManufacturerId)
                    .HasColumnName("ManufacturerID")
                    .HasMaxLength(15);
            });

            modelBuilder.Entity<BusinessNature>(entity =>
            {
                entity.HasKey(e => e.Name);

                entity.Property(e => e.Name)
                    .HasMaxLength(255)
                    .ValueGeneratedNever();

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Id)
                    .HasColumnName("ID")
                    .ValueGeneratedOnAdd();
            });

            modelBuilder.Entity<CashCustomerRec>(entity =>
            {
                entity.HasKey(e => e.CustomerId);

                entity.ToTable("Cash_Customer_rec");

                entity.Property(e => e.CustomerId).HasColumnName("CustomerID");

                entity.Property(e => e.Address).HasMaxLength(255);

                entity.Property(e => e.CategoryId).HasColumnName("CategoryID");

                entity.Property(e => e.ContactPerson).HasMaxLength(30);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.CustomerName)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.Discount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Dob)
                    .HasColumnName("DOB")
                    .HasColumnType("datetime");

                entity.Property(e => e.Fax).HasMaxLength(30);

                entity.Property(e => e.Flag).HasDefaultValueSql("(1)");

                entity.Property(e => e.MembershipCode).HasMaxLength(30);

                entity.Property(e => e.ModifiedDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Telephone).HasMaxLength(30);
            });

            modelBuilder.Entity<CatalogAbstract>(entity =>
            {
                entity.HasKey(e => e.CatalogId)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.CatalogId).HasColumnName("CatalogID");

                entity.Property(e => e.UploadDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");
            });

            modelBuilder.Entity<City>(entity =>
            {
                entity.HasKey(e => e.CityId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.CityName)
                    .HasName("IX_City")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.CityId).HasColumnName("CityID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CityName)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.DistrictId).HasColumnName("DistrictID");

                entity.Property(e => e.StateId).HasColumnName("StateID");

                entity.Property(e => e.Stdcode)
                    .HasColumnName("STDCode")
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<ClaimsNote>(entity =>
            {
                entity.HasKey(e => e.ClaimId)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.ClaimId).HasColumnName("ClaimID");

                entity.Property(e => e.Balance).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.CancelDate).HasColumnType("datetime");

                entity.Property(e => e.Cancelusername)
                    .HasColumnName("cancelusername")
                    .HasMaxLength(50);

                entity.Property(e => e.ClaimDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.ClaimRfa).HasColumnName("ClaimRFA");

                entity.Property(e => e.ClaimValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ClientId).HasColumnName("Client_ID");

                entity.Property(e => e.CompanyCreditNoteNo).HasMaxLength(100);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.DocumentReference).HasMaxLength(50);

                entity.Property(e => e.Remarks).HasMaxLength(200);

                entity.Property(e => e.SettlementDate).HasColumnType("datetime");

                entity.Property(e => e.SettlementValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Status).HasDefaultValueSql("(0)");

                entity.Property(e => e.TaxAmount)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("((0))");

                entity.Property(e => e.VendorId)
                    .IsRequired()
                    .HasColumnName("VendorID")
                    .HasMaxLength(15);
            });

            modelBuilder.Entity<ClientInformation>(entity =>
            {
                entity.HasKey(e => e.ClientId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.Name)
                    .HasName("IX_ClientInformation")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.ClientId).HasColumnName("ClientID");

                entity.Property(e => e.Description)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<CollectionsReceived>(entity =>
            {
                entity.HasKey(e => e.DocSerial);

                entity.Property(e => e.Balance).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Bank).HasMaxLength(50);

                entity.Property(e => e.Beat).HasMaxLength(50);

                entity.Property(e => e.Branch).HasMaxLength(50);

                entity.Property(e => e.BranchForumCode).HasMaxLength(15);

                entity.Property(e => e.ChequeDate).HasColumnType("datetime");

                entity.Property(e => e.ChequeDetails).HasMaxLength(50);

                entity.Property(e => e.CreationTime).HasColumnType("datetime");

                entity.Property(e => e.CustomerId)
                    .HasColumnName("CustomerID")
                    .HasMaxLength(15);

                entity.Property(e => e.DocReference).HasMaxLength(255);

                entity.Property(e => e.DocumentDate).HasColumnType("datetime");

                entity.Property(e => e.DocumentReference).HasMaxLength(512);

                entity.Property(e => e.FullDocId)
                    .HasColumnName("FullDocID")
                    .HasMaxLength(30);

                entity.Property(e => e.Value).HasColumnType("decimal(18, 6)");
            });

            modelBuilder.Entity<Comversion>(entity =>
            {
                entity.HasKey(e => e.ComponentName);

                entity.ToTable("COMVersion");

                entity.Property(e => e.ComponentName)
                    .HasMaxLength(100)
                    .ValueGeneratedNever();

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.InstallationId).HasColumnName("Installation_ID");

                entity.Property(e => e.ModifiedDate).HasColumnType("datetime");

                entity.Property(e => e.Version).HasMaxLength(15);
            });

            modelBuilder.Entity<ConversionTable>(entity =>
            {
                entity.HasKey(e => e.ConversionId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.ConversionUnit)
                    .HasName("IX_ConversionTable")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.ConversionId).HasColumnName("ConversionID");

                entity.Property(e => e.ConversionUnit)
                    .IsRequired()
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<Country>(entity =>
            {
                entity.HasKey(e => e.CountryId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.Country1)
                    .HasName("IX_Country")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.CountryId).HasColumnName("CountryID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.Country1)
                    .IsRequired()
                    .HasColumnName("Country")
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<CreditNote>(entity =>
            {
                entity.HasKey(e => e.CreditId);

                entity.HasIndex(e => e.DocumentId)
                    .HasName("IX_CreditNote");

                entity.HasIndex(e => new { e.CustomerId, e.NoteValue, e.DocumentReference, e.DocRef })
                    .HasName("<Name of Missing Index, sysname,>");

                entity.HasIndex(e => new { e.CustomerId, e.NoteValue, e.DocumentDate, e.DocumentReference, e.DocRef })
                    .HasName("CreditNote_CNDD1");

                entity.Property(e => e.CreditId).HasColumnName("CreditID");

                entity.Property(e => e.AccountId).HasColumnName("AccountID");

                entity.Property(e => e.Balance).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.CancelMemo)
                    .HasColumnName("Cancel_Memo")
                    .HasMaxLength(255);

                entity.Property(e => e.CancelUser).HasMaxLength(100);

                entity.Property(e => e.CancelledDate)
                    .HasColumnName("Cancelled_Date")
                    .HasColumnType("datetime");

                entity.Property(e => e.ClaimRfa).HasColumnName("ClaimRFA");

                entity.Property(e => e.ClientId).HasColumnName("Client_ID");

                entity.Property(e => e.CreationTime)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.CustomerId)
                    .HasColumnName("CustomerID")
                    .HasMaxLength(15);

                entity.Property(e => e.DocPrefix).HasMaxLength(50);

                entity.Property(e => e.DocRef).HasMaxLength(50);

                entity.Property(e => e.DocSerialType).HasMaxLength(100);

                entity.Property(e => e.DocumentDate).HasColumnType("datetime");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.DocumentReference).HasMaxLength(510);

                entity.Property(e => e.Flag).HasDefaultValueSql("(0)");

                entity.Property(e => e.FreeSkuflag).HasColumnName("FreeSKUFlag");

                entity.Property(e => e.GiftVoucherNo).HasMaxLength(255);

                entity.Property(e => e.GvcollectedOn)
                    .HasColumnName("GVCollectedOn")
                    .HasColumnType("datetime");

                entity.Property(e => e.LoyaltyId)
                    .HasColumnName("LoyaltyID")
                    .HasMaxLength(255);

                entity.Property(e => e.Memo).HasMaxLength(255);

                entity.Property(e => e.NoteValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.OriginalCreditId).HasColumnName("OriginalCreditID");

                entity.Property(e => e.PayoutId).HasColumnName("PayoutID");

                entity.Property(e => e.RefDocId).HasColumnName("RefDocID");

                entity.Property(e => e.SalesmanId).HasColumnName("SalesmanID");

                entity.Property(e => e.UserName).HasMaxLength(100);

                entity.Property(e => e.VendorId)
                    .HasColumnName("VendorID")
                    .HasMaxLength(15);
            });

            modelBuilder.Entity<CreditTerm>(entity =>
            {
                entity.HasKey(e => e.CreditId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.Description)
                    .HasName("UniqueDesc")
                    .IsUnique();

                entity.Property(e => e.CreditId).HasColumnName("CreditID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.Description)
                    .IsRequired()
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<Customer>(entity =>
            {
                entity.HasKey(e => e.CustomerId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.CompanyName)
                    .HasName("IX_Customer")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.CustomerId)
                    .HasColumnName("CustomerID")
                    .HasMaxLength(15)
                    .ValueGeneratedNever();

                entity.Property(e => e.AccountId).HasColumnName("AccountID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.AddCollDiscPercentage).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.AlternateCode).HasMaxLength(20);

                entity.Property(e => e.AlternateName)
                    .HasColumnName("Alternate_Name")
                    .HasMaxLength(250);

                entity.Property(e => e.AreaId)
                    .HasColumnName("AreaID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.Awareness).HasMaxLength(100);

                entity.Property(e => e.BillingAddress).HasMaxLength(255);

                entity.Property(e => e.BillingStateId).HasColumnName("BillingStateID");

                entity.Property(e => e.CityId)
                    .HasColumnName("CityID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.CollectedPoints).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.CompanyName)
                    .HasColumnName("Company_Name")
                    .HasMaxLength(150);

                entity.Property(e => e.ContactPerson).HasMaxLength(255);

                entity.Property(e => e.CountryId)
                    .HasColumnName("CountryID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.CreditLimit).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Cst)
                    .HasColumnName("CST")
                    .HasMaxLength(50);

                entity.Property(e => e.CustomerCategory).HasDefaultValueSql("(0)");

                entity.Property(e => e.CustomerPassword)
                    .HasColumnName("Customer_Password")
                    .HasMaxLength(50);

                entity.Property(e => e.DefaultBeatId).HasColumnName("DefaultBeatID");

                entity.Property(e => e.Discount)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.Dlnumber)
                    .HasColumnName("DLNumber")
                    .HasMaxLength(50);

                entity.Property(e => e.Dlnumber21)
                    .HasColumnName("DLNumber21")
                    .HasMaxLength(50);

                entity.Property(e => e.DnDflag).HasColumnName("DnDFlag");

                entity.Property(e => e.Dob)
                    .HasColumnName("DOB")
                    .HasColumnType("datetime");

                entity.Property(e => e.Email).HasMaxLength(50);

                entity.Property(e => e.Fax).HasMaxLength(100);

                entity.Property(e => e.FirstName)
                    .HasColumnName("First_Name")
                    .HasMaxLength(200);

                entity.Property(e => e.Gstin)
                    .HasColumnName("GSTIN")
                    .HasMaxLength(15);

                entity.Property(e => e.Hhcustomer).HasColumnName("HHCustomer");

                entity.Property(e => e.MembershipCode).HasMaxLength(100);

                entity.Property(e => e.MobileNumber).HasMaxLength(50);

                entity.Property(e => e.Modifieddate).HasColumnType("datetime");

                entity.Property(e => e.Pannumber)
                    .HasColumnName("PANNumber")
                    .HasMaxLength(100);

                entity.Property(e => e.PaymentMode).HasColumnName("Payment_Mode");

                entity.Property(e => e.Phone).HasMaxLength(50);

                entity.Property(e => e.Pincode).HasMaxLength(50);

                entity.Property(e => e.Potential).HasMaxLength(100);

                entity.Property(e => e.RcsoutletId)
                    .HasColumnName("RCSOutletID")
                    .HasMaxLength(50);

                entity.Property(e => e.RecHhcustomerId)
                    .HasColumnName("RecHHCustomerID")
                    .HasMaxLength(15);

                entity.Property(e => e.RedeemedPoints).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ReferredBy).HasMaxLength(200);

                entity.Property(e => e.Residence).HasMaxLength(50);

                entity.Property(e => e.SalutationId).HasColumnName("SalutationID");

                entity.Property(e => e.SecondName)
                    .HasColumnName("Second_name")
                    .HasMaxLength(200);

                entity.Property(e => e.SegmentId).HasColumnName("SegmentID");

                entity.Property(e => e.SequenceNo)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.ShippingAddress).HasMaxLength(255);

                entity.Property(e => e.ShippingStateId).HasColumnName("ShippingStateID");

                entity.Property(e => e.Smsalert).HasColumnName("SMSAlert");

                entity.Property(e => e.StateId)
                    .HasColumnName("StateID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.SubChannelId)
                    .HasColumnName("SubChannelID")
                    .HasMaxLength(50);

                entity.Property(e => e.TinNumber)
                    .HasColumnName("TIN_Number")
                    .HasMaxLength(50);

                entity.Property(e => e.Tngst)
                    .HasColumnName("TNGST")
                    .HasMaxLength(50);

                entity.Property(e => e.TradeCategoryId).HasColumnName("TradeCategoryID");

                entity.Property(e => e.ZoneId)
                    .HasColumnName("ZoneID")
                    .HasDefaultValueSql("((0))");
            });

            modelBuilder.Entity<CustomerCategory>(entity =>
            {
                entity.HasKey(e => e.CategoryId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.CategoryName)
                    .HasName("IX_CustomerCategory")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.CategoryId).HasColumnName("CategoryID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CategoryName)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");
            });

            modelBuilder.Entity<CustomerChannel>(entity =>
            {
                entity.HasKey(e => e.ChannelType)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("Customer_Channel");

                entity.HasIndex(e => e.ChannelDesc)
                    .HasName("IX_Channel")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.ChannelDesc)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.Code).HasMaxLength(100);
            });

            modelBuilder.Entity<CustomerHierarchy>(entity =>
            {
                entity.HasKey(e => e.HierarchyId);

                entity.Property(e => e.HierarchyId)
                    .HasColumnName("HierarchyID")
                    .ValueGeneratedNever();

                entity.Property(e => e.HierarchyName).HasMaxLength(255);
            });

            modelBuilder.Entity<CustomerSegment>(entity =>
            {
                entity.HasKey(e => e.SegmentId);

                entity.Property(e => e.SegmentId).HasColumnName("SegmentID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Description).HasMaxLength(255);

                entity.Property(e => e.ModifiedDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.ParentId)
                    .HasColumnName("ParentID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.SegmentCode).HasMaxLength(255);

                entity.Property(e => e.SegmentName).HasMaxLength(255);
            });

            modelBuilder.Entity<DebitNote>(entity =>
            {
                entity.HasKey(e => e.DebitId);

                entity.HasIndex(e => e.DocumentId)
                    .HasName("IX_DebitNote");

                entity.Property(e => e.DebitId).HasColumnName("DebitID");

                entity.Property(e => e.AccountId).HasColumnName("AccountID");

                entity.Property(e => e.Balance).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.CancelMemo)
                    .HasColumnName("Cancel_Memo")
                    .HasMaxLength(255);

                entity.Property(e => e.CancelUser).HasMaxLength(50);

                entity.Property(e => e.CancelledDate)
                    .HasColumnName("Cancelled_Date")
                    .HasColumnType("datetime");

                entity.Property(e => e.ClientId).HasColumnName("Client_ID");

                entity.Property(e => e.CreationTime)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.CustomerId)
                    .HasColumnName("CustomerID")
                    .HasMaxLength(15);

                entity.Property(e => e.DocRef).HasMaxLength(50);

                entity.Property(e => e.DocSerialType).HasMaxLength(100);

                entity.Property(e => e.DocumentDate).HasColumnType("datetime");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.DocumentReference).HasMaxLength(510);

                entity.Property(e => e.Memo).HasMaxLength(255);

                entity.Property(e => e.NoteValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.OriginalDebitId).HasColumnName("OriginalDebitID");

                entity.Property(e => e.RefDocId).HasColumnName("RefDocID");

                entity.Property(e => e.Reference).HasMaxLength(100);

                entity.Property(e => e.SalesmanId).HasColumnName("SalesmanID");

                entity.Property(e => e.UserName).HasMaxLength(100);

                entity.Property(e => e.VendorId)
                    .HasColumnName("VendorID")
                    .HasMaxLength(15);
            });

            modelBuilder.Entity<Deposits>(entity =>
            {
                entity.HasKey(e => e.DepositId);

                entity.HasIndex(e => e.DepositDate)
                    .HasName("IX_Deposits");

                entity.Property(e => e.DepositId).HasColumnName("DepositID");

                entity.Property(e => e.AccountId).HasColumnName("AccountID");

                entity.Property(e => e.ChequeDate).HasColumnType("datetime");

                entity.Property(e => e.ChequeId).HasColumnName("ChequeID");

                entity.Property(e => e.CreationDate).HasColumnType("datetime");

                entity.Property(e => e.Denominations).HasMaxLength(50);

                entity.Property(e => e.DepositDate).HasColumnType("datetime");

                entity.Property(e => e.FullDocId)
                    .HasColumnName("FullDocID")
                    .HasMaxLength(50);

                entity.Property(e => e.Narration).HasMaxLength(2000);

                entity.Property(e => e.StaffId).HasColumnName("StaffID");

                entity.Property(e => e.ToAccountId).HasColumnName("ToAccountID");

                entity.Property(e => e.Value).HasColumnType("decimal(18, 6)");
            });

            modelBuilder.Entity<Disclaimer>(entity =>
            {
                entity.HasKey(e => e.TranId)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.TranId)
                    .HasColumnName("TranID")
                    .HasMaxLength(50)
                    .ValueGeneratedNever();

                entity.Property(e => e.DisclaimerText).HasMaxLength(4000);
            });

            modelBuilder.Entity<DispatchAbstract>(entity =>
            {
                entity.HasKey(e => e.DispatchId)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.DispatchId).HasColumnName("DispatchID");

                entity.Property(e => e.BeatId).HasColumnName("BeatID");

                entity.Property(e => e.BillingAddress).HasMaxLength(255);

                entity.Property(e => e.CancelDate).HasColumnType("datetime");

                entity.Property(e => e.Cancelusername)
                    .HasColumnName("cancelusername")
                    .HasMaxLength(50);

                entity.Property(e => e.ClientId).HasColumnName("ClientID");

                entity.Property(e => e.CreationTime)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.CustomerId)
                    .HasColumnName("CustomerID")
                    .HasMaxLength(15);

                entity.Property(e => e.DispatchDate).HasColumnType("datetime");

                entity.Property(e => e.DocRef).HasMaxLength(255);

                entity.Property(e => e.DocSerialType).HasMaxLength(100);

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.GroupId)
                    .HasColumnName("GroupID")
                    .HasMaxLength(1000);

                entity.Property(e => e.InvoiceId).HasColumnName("InvoiceID");

                entity.Property(e => e.Memo1).HasMaxLength(256);

                entity.Property(e => e.Memo2).HasMaxLength(256);

                entity.Property(e => e.Memo3).HasMaxLength(256);

                entity.Property(e => e.MemoLabel1).HasMaxLength(255);

                entity.Property(e => e.MemoLabel2).HasMaxLength(255);

                entity.Property(e => e.MemoLabel3).HasMaxLength(255);

                entity.Property(e => e.NewInvoiceId).HasColumnName("NewInvoiceID");

                entity.Property(e => e.NewRefNumber).HasMaxLength(255);

                entity.Property(e => e.OriginalReference).HasColumnName("Original_Reference");

                entity.Property(e => e.RefNumber).HasMaxLength(255);

                entity.Property(e => e.Remarks).HasMaxLength(255);

                entity.Property(e => e.SalesmanId).HasColumnName("SalesmanID");

                entity.Property(e => e.ShippingAddress).HasMaxLength(255);

                entity.Property(e => e.UserName).HasMaxLength(100);
            });

            modelBuilder.Entity<Doctor>(entity =>
            {
                entity.HasKey(e => e.Id)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("DOCTOR");

                entity.HasIndex(e => e.Name)
                    .HasName("UQ__DOCTOR__3BAC7838")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.Id).HasColumnName("ID");

                entity.Property(e => e.Name)
                    .IsRequired()
                    .HasMaxLength(128);
            });

            modelBuilder.Entity<DocumentNumbers>(entity =>
            {
                entity.HasKey(e => e.DocType)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.DocType).ValueGeneratedNever();

                entity.Property(e => e.DocumentId)
                    .HasColumnName("DocumentID")
                    .HasDefaultValueSql("(1)");
            });

            modelBuilder.Entity<FormatInfo>(entity =>
            {
                entity.HasKey(e => e.Id)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.FormatId)
                    .HasName("IX_FormatInfo")
                    .ForSqlServerIsClustered();

                entity.Property(e => e.Id).HasColumnName("ID");

                entity.Property(e => e.ColAlignment).HasDefaultValueSql("(0)");

                entity.Property(e => e.ColWidth).HasDefaultValueSql("(1440)");

                entity.Property(e => e.FormatId).HasColumnName("FormatID");
            });

            modelBuilder.Entity<Grnabstract>(entity =>
            {
                entity.HasKey(e => e.Grnid)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("GRNAbstract");

                entity.Property(e => e.Grnid).HasColumnName("GRNID");

                entity.Property(e => e.BillId).HasColumnName("BillID");

                entity.Property(e => e.CancelDate).HasColumnType("datetime");

                entity.Property(e => e.CancelUser).HasMaxLength(50);

                entity.Property(e => e.ClientId).HasColumnName("ClientID");

                entity.Property(e => e.CreationTime)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DocRef).HasMaxLength(255);

                entity.Property(e => e.DocSerialType).HasMaxLength(100);

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.DocumentIdref)
                    .HasColumnName("DocumentIDRef")
                    .HasMaxLength(50);

                entity.Property(e => e.DocumentReference).HasMaxLength(510);

                entity.Property(e => e.Grndate)
                    .HasColumnName("GRNDate")
                    .HasColumnType("datetime");

                entity.Property(e => e.Grnidref).HasColumnName("GRNIDRef");

                entity.Property(e => e.Grnstatus).HasColumnName("GRNStatus");

                entity.Property(e => e.NewBillId).HasColumnName("NewBillID");

                entity.Property(e => e.OriginalGrn).HasColumnName("OriginalGRN");

                entity.Property(e => e.Ponumber)
                    .HasColumnName("PONumber")
                    .HasMaxLength(255);

                entity.Property(e => e.Ponumbers)
                    .HasColumnName("PONumbers")
                    .HasMaxLength(255);

                entity.Property(e => e.RecdInvoiceId).HasColumnName("RecdInvoiceID");

                entity.Property(e => e.Remarks).HasMaxLength(255);

                entity.Property(e => e.UserName).HasMaxLength(255);

                entity.Property(e => e.VendorId)
                    .IsRequired()
                    .HasColumnName("VendorID")
                    .HasMaxLength(15);
            });

            modelBuilder.Entity<Groups>(entity =>
            {
                entity.HasKey(e => e.GroupName)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.GroupName)
                    .HasMaxLength(50)
                    .ValueGeneratedNever();

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Permission).HasColumnType("text");
            });

            modelBuilder.Entity<Gstcomponent>(entity =>
            {
                entity.HasKey(e => e.GstcomponentCode);

                entity.ToTable("GSTComponent");

                entity.Property(e => e.GstcomponentCode)
                    .HasColumnName("GSTComponentCode")
                    .ValueGeneratedNever();

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.GstcomponentDesc)
                    .IsRequired()
                    .HasColumnName("GSTComponentDesc")
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<InvoiceAbstract>(entity =>
            {
                entity.HasKey(e => e.InvoiceId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.CustomerId)
                    .HasName("IX_CustomerID");

                entity.HasIndex(e => new { e.InvoiceId, e.InvoiceDate, e.CustomerId, e.NetValue, e.Status, e.ReferenceNumber, e.GstfullDocId, e.InvoiceType })
                    .HasName("NONCLUSTERED_InvoiceAbstract_1");

                entity.HasIndex(e => new { e.InvoiceId, e.InvoiceDate, e.CustomerId, e.NetValue, e.Status, e.RoundOffAmount, e.DeliveryDate, e.GstfullDocId, e.SalesmanId, e.BeatId, e.InvoiceType })
                    .HasName("<Name of Missing Index, sysname,>");

                entity.HasIndex(e => new { e.InvoiceId, e.InvoiceDate, e.CustomerId, e.NetValue, e.Status, e.SalesmanId, e.BeatId, e.RoundOffAmount, e.DeliveryDate, e.GstfullDocId, e.InvoiceType })
                    .HasName("NONCLUSTERED_InvoiceAbstract");

                entity.HasIndex(e => new { e.InvoiceId, e.InvoiceDate, e.CustomerId, e.NetValue, e.Status, e.Balance, e.SalesmanId, e.BeatId, e.RoundOffAmount, e.DeliveryDate, e.GstfullDocId, e.InvoiceType })
                    .HasName("InvoiceAbstract_IDDATECUSVALSTABALSIDBIDRUPDELDATEFULLDOC1");

                entity.Property(e => e.InvoiceId).HasColumnName("InvoiceID");

                entity.Property(e => e.AdditionalDiscount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.AddlDiscountValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.AdjRef).HasMaxLength(255);

                entity.Property(e => e.AdjustedAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.AdjustmentValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.AlternateCgcustomerName)
                    .HasColumnName("AlternateCGCustomerName")
                    .HasMaxLength(150);

                entity.Property(e => e.AmendReasonId).HasColumnName("AmendReasonID");

                entity.Property(e => e.AmountRecd).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Balance).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.BeatId).HasColumnName("BeatID");

                entity.Property(e => e.BillingAddress).HasMaxLength(255);

                entity.Property(e => e.BranchCode).HasMaxLength(15);

                entity.Property(e => e.CancelDate).HasColumnType("datetime");

                entity.Property(e => e.CancelReasonId).HasColumnName("CancelReasonID");

                entity.Property(e => e.CancelUser).HasMaxLength(50);

                entity.Property(e => e.CformNo)
                    .HasColumnName("CFormNo")
                    .HasMaxLength(30);

                entity.Property(e => e.ClaimedAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ClientId).HasColumnName("ClientID");

                entity.Property(e => e.CreationTime)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.CustomerId)
                    .HasColumnName("CustomerID")
                    .HasMaxLength(15);

                entity.Property(e => e.CustomerPoints).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.DeliveryDate).HasColumnType("datetime");

                entity.Property(e => e.Denominations).HasMaxLength(2000);

                entity.Property(e => e.DformNo)
                    .HasColumnName("DFormNo")
                    .HasMaxLength(30);

                entity.Property(e => e.DiscountPercentage).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.DiscountValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.DocReference).HasMaxLength(255);

                entity.Property(e => e.DocSerialType).HasMaxLength(100);

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.DstypeId).HasColumnName("DSTypeID");

                entity.Property(e => e.ExciseDuty).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Freight).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.GoodsValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.GrossValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.GroupId)
                    .HasColumnName("GroupID")
                    .HasMaxLength(1000);

                entity.Property(e => e.GstdocId).HasColumnName("GSTDocID");

                entity.Property(e => e.Gstflag).HasColumnName("GSTFlag");

                entity.Property(e => e.GstfullDocId)
                    .HasColumnName("GSTFullDocID")
                    .HasMaxLength(250);

                entity.Property(e => e.Gstin)
                    .HasColumnName("GSTIN")
                    .HasMaxLength(30);

                entity.Property(e => e.InvoiceDate).HasColumnType("datetime");

                entity.Property(e => e.InvoiceReference).HasMaxLength(50);

                entity.Property(e => e.InvoiceSchemeId)
                    .HasColumnName("InvoiceSchemeID")
                    .HasMaxLength(510);

                entity.Property(e => e.LastPrintOn).HasColumnType("datetime");

                entity.Property(e => e.Memo1).HasMaxLength(255);

                entity.Property(e => e.Memo2).HasMaxLength(255);

                entity.Property(e => e.Memo3).HasMaxLength(255);

                entity.Property(e => e.MemoLabel1).HasMaxLength(255);

                entity.Property(e => e.MemoLabel2).HasMaxLength(255);

                entity.Property(e => e.MemoLabel3).HasMaxLength(255);

                entity.Property(e => e.MultipleSchemeDetails).HasMaxLength(2550);

                entity.Property(e => e.NetValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.NewInvoiceReference).HasMaxLength(50);

                entity.Property(e => e.NewReference).HasMaxLength(255);

                entity.Property(e => e.PaymentDate).HasColumnType("datetime");

                entity.Property(e => e.PaymentDetails).HasMaxLength(255);

                entity.Property(e => e.ProductDiscount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ReferenceNumber).HasMaxLength(255);

                entity.Property(e => e.RoundOffAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.SalesmanId).HasColumnName("SalesmanID");

                entity.Property(e => e.SchemeDiscountAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.SchemeDiscountPercentage).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.SchemeId).HasColumnName("SchemeID");

                entity.Property(e => e.ServiceCharge).HasMaxLength(255);

                entity.Property(e => e.ShippingAddress).HasMaxLength(255);

                entity.Property(e => e.Sonumber)
                    .HasColumnName("SONumber")
                    .HasMaxLength(255);

                entity.Property(e => e.SrhhReference)
                    .HasColumnName("SRHH_Reference")
                    .HasMaxLength(100);

                entity.Property(e => e.SrinvoiceId).HasColumnName("SRInvoiceID");

                entity.Property(e => e.TaxLocation).HasMaxLength(50);

                entity.Property(e => e.TaxOnMrp).HasColumnName("TaxOnMRP");

                entity.Property(e => e.TotalTaxApplicable).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.TotalTaxSuffered).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.UserName).HasMaxLength(50);

                entity.Property(e => e.VanNumber).HasMaxLength(50);

                entity.Property(e => e.VatTaxAmount).HasColumnType("decimal(18, 6)");
            });

            modelBuilder.Entity<InvoiceAbstractReceived>(entity =>
            {
                entity.HasKey(e => e.InvoiceId)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.InvoiceId).HasColumnName("InvoiceID");

                entity.Property(e => e.AdditionalDiscount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.AdditionalDiscountAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.AddlDiscountAmount)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.AddlDiscountPercentage)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.AdjustedAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.AdjustmentDocReference).HasMaxLength(255);

                entity.Property(e => e.BillingAddress).HasMaxLength(255);

                entity.Property(e => e.CreationTime).HasColumnType("datetime");

                entity.Property(e => e.DiscountPercentage).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.DiscountValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.DocumentId)
                    .HasColumnName("DocumentID")
                    .HasMaxLength(50);

                entity.Property(e => e.ExciseDuty).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ForumCode).HasMaxLength(20);

                entity.Property(e => e.Freight).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.GrossValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Gstflag).HasColumnName("GSTFlag");

                entity.Property(e => e.Gstin)
                    .HasColumnName("GSTIN")
                    .HasMaxLength(15);

                entity.Property(e => e.InvoiceDate).HasColumnType("datetime");

                entity.Property(e => e.InvoiceTime).HasColumnType("datetime");

                entity.Property(e => e.NetAmountAfterAdjustment).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.NetTaxAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.NetValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.OctroiAmount)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.Odnumber)
                    .HasColumnName("ODNumber")
                    .HasMaxLength(50);

                entity.Property(e => e.PaymentDate).HasColumnType("datetime");

                entity.Property(e => e.Podate)
                    .HasColumnName("PODate")
                    .HasColumnType("datetime");

                entity.Property(e => e.PoserialNumber)
                    .HasColumnName("POSerialNumber")
                    .HasMaxLength(50);

                entity.Property(e => e.ProductDiscount)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.RecdXmlackDocId).HasColumnName("RecdXMLAckDocID");

                entity.Property(e => e.Reference).HasMaxLength(50);

                entity.Property(e => e.ShippingAddress).HasMaxLength(255);

                entity.Property(e => e.Status).HasDefaultValueSql("(0)");

                entity.Property(e => e.TaxLocation).HasMaxLength(50);

                entity.Property(e => e.TaxType).HasMaxLength(50);

                entity.Property(e => e.UserName).HasMaxLength(50);

                entity.Property(e => e.VendorId)
                    .IsRequired()
                    .HasColumnName("VendorID")
                    .HasMaxLength(15);
            });

            modelBuilder.Entity<ItemCategories>(entity =>
            {
                entity.HasKey(e => e.CategoryId);

                entity.HasIndex(e => e.CategoryName)
                    .HasName("IX_ItemCategories")
                    .IsUnique();

                entity.Property(e => e.CategoryId).HasColumnName("CategoryID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CategoryName)
                    .IsRequired()
                    .HasColumnName("Category_Name")
                    .HasMaxLength(255);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Description).HasMaxLength(255);

                entity.Property(e => e.ModifiedDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.ParentId)
                    .HasColumnName("ParentID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.PriceOption).HasColumnName("Price_Option");

                entity.Property(e => e.TrackInventory).HasColumnName("Track_Inventory");
            });

            modelBuilder.Entity<Itemhierarchy>(entity =>
            {
                entity.HasKey(e => e.HierarchyId);

                entity.Property(e => e.HierarchyId).ValueGeneratedNever();

                entity.Property(e => e.HierarchyName).HasMaxLength(255);
            });

            modelBuilder.Entity<Items>(entity =>
            {
                entity.HasKey(e => e.ProductCode);

                entity.HasIndex(e => e.Alias)
                    .HasName("Alias_Unique")
                    .IsUnique();

                entity.HasIndex(e => e.ProductName)
                    .HasName("IX_Items")
                    .IsUnique();

                entity.Property(e => e.ProductCode)
                    .HasColumnName("Product_Code")
                    .HasMaxLength(15)
                    .ValueGeneratedNever();

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.Adhocamount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Alias).HasMaxLength(25);

                entity.Property(e => e.Asl)
                    .HasColumnName("ASL")
                    .HasDefaultValueSql("((0))");

                entity.Property(e => e.BrandId).HasColumnName("BrandID");

                entity.Property(e => e.CaseConversion)
                    .HasColumnName("Case_Conversion")
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.CaseUom)
                    .HasColumnName("Case_UOM")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.CategorizationId).HasColumnName("CategorizationID");

                entity.Property(e => e.CategoryId).HasColumnName("CategoryID");

                entity.Property(e => e.ComboId).HasColumnName("ComboID");

                entity.Property(e => e.CompanyMargin)
                    .HasColumnName("Company_Margin")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.CompanyPrice)
                    .HasColumnName("Company_Price")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ConversionFactor).HasColumnType("decimal(18, 9)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DefaultUom).HasColumnName("DefaultUOM");

                entity.Property(e => e.Description).HasMaxLength(2000);

                entity.Property(e => e.EanNumber)
                    .HasColumnName("EAN_NUMBER")
                    .HasMaxLength(50);

                entity.Property(e => e.Ecp)
                    .HasColumnName("ECP")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.FreeSkuflag).HasColumnName("FreeSKUFlag");

                entity.Property(e => e.Hsnnumber)
                    .HasColumnName("HSNNumber")
                    .HasMaxLength(15);

                entity.Property(e => e.Hyperlink).HasMaxLength(256);

                entity.Property(e => e.ManufacturerId).HasColumnName("ManufacturerID");

                entity.Property(e => e.MinOrderQty).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ModifiedDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Mrp)
                    .HasColumnName("MRP")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.MrpperPack)
                    .HasColumnName("MRPPerPack")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.OpeningStock)
                    .HasColumnName("Opening_Stock")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.OpeningStockValue)
                    .HasColumnName("Opening_Stock_Value")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.OrderQty)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.PendingRequest).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Pfm)
                    .HasColumnName("PFM")
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("((0))");

                entity.Property(e => e.PreferredVendor)
                    .HasColumnName("Preferred_Vendor")
                    .HasMaxLength(15);

                entity.Property(e => e.PriceatUomlevel).HasColumnName("PriceatUOMLevel");

                entity.Property(e => e.ProductName)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.Ptr)
                    .HasColumnName("PTR")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Pts)
                    .HasColumnName("PTS")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.PurchasePrice)
                    .HasColumnName("Purchase_Price")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.PurchasedAt).HasColumnName("Purchased_At");

                entity.Property(e => e.ReportingUnit).HasColumnType("decimal(18, 9)");

                entity.Property(e => e.ReportingUom).HasColumnName("ReportingUOM");

                entity.Property(e => e.RetailerMargin)
                    .HasColumnName("Retailer_Margin")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.SaleId).HasColumnName("SaleID");

                entity.Property(e => e.SalePrice)
                    .HasColumnName("Sale_Price")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.SaleTax).HasColumnName("Sale_Tax");

                entity.Property(e => e.SchemeId).HasColumnName("SchemeID");

                entity.Property(e => e.SoldAs).HasMaxLength(50);

                entity.Property(e => e.StockNorm).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.StockistMargin)
                    .HasColumnName("Stockist_Margin")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.SupplyingBranch).HasMaxLength(50);

                entity.Property(e => e.TaxInclusiveRate).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ToqPurchase).HasColumnName("TOQ_Purchase");

                entity.Property(e => e.ToqSales).HasColumnName("TOQ_Sales");

                entity.Property(e => e.TrackBatches).HasColumnName("Track_Batches");

                entity.Property(e => e.TrackPkd).HasColumnName("TrackPKD");

                entity.Property(e => e.Uom).HasColumnName("UOM");

                entity.Property(e => e.Uom1).HasColumnName("UOM1");

                entity.Property(e => e.Uom1Conversion)
                    .HasColumnName("UOM1_Conversion")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Uom2).HasColumnName("UOM2");

                entity.Property(e => e.Uom2Conversion)
                    .HasColumnName("UOM2_Conversion")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.UserDefinedCode)
                    .HasMaxLength(255)
                    .HasDefaultValueSql("('')");

                entity.Property(e => e.VirtualTrackBatches).HasColumnName("Virtual_Track_Batches");
            });

            modelBuilder.Entity<ItemSchemes>(entity =>
            {
                entity.HasKey(e => new { e.SchemeId, e.ProductCode })
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.SchemeId).HasColumnName("SchemeID");

                entity.Property(e => e.ProductCode)
                    .HasColumnName("Product_code")
                    .HasMaxLength(15);
            });

            modelBuilder.Entity<Manufacturer>(entity =>
            {
                entity.HasKey(e => e.ManufacturerId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.ManufacturerName)
                    .HasName("IX_Manufacturer")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.ManufacturerId).HasColumnName("ManufacturerID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.ManufacturerName)
                    .IsRequired()
                    .HasColumnName("Manufacturer_Name")
                    .HasMaxLength(255);

                entity.Property(e => e.Manufacturercode)
                    .HasColumnName("manufacturercode")
                    .HasMaxLength(20);
            });

            modelBuilder.Entity<Poabstract>(entity =>
            {
                entity.HasKey(e => e.Ponumber)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("POAbstract");

                entity.Property(e => e.Ponumber).HasColumnName("PONumber");

                entity.Property(e => e.BillingAddress).HasMaxLength(255);

                entity.Property(e => e.CancelDate).HasColumnType("datetime");

                entity.Property(e => e.CancelUserName).HasMaxLength(50);

                entity.Property(e => e.ClientId)
                    .HasColumnName("ClientID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.CreationTime)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.CreditTerm).HasDefaultValueSql("(0)");

                entity.Property(e => e.DocRef).HasMaxLength(255);

                entity.Property(e => e.DocumentId)
                    .HasColumnName("DocumentID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.DocumentReference).HasDefaultValueSql("(0)");

                entity.Property(e => e.Grnid)
                    .HasColumnName("GRNID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.NewGrnid)
                    .HasColumnName("NewGRNID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.OriginalPo)
                    .HasColumnName("OriginalPO")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.Podate)
                    .HasColumnName("PODate")
                    .HasColumnType("datetime");

                entity.Property(e => e.Poidreference).HasColumnName("POIDReference");

                entity.Property(e => e.Poreference)
                    .HasColumnName("POReference")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.Reference).HasMaxLength(50);

                entity.Property(e => e.Remarks).HasMaxLength(255);

                entity.Property(e => e.RequiredDate).HasColumnType("datetime");

                entity.Property(e => e.ShippingAddress).HasMaxLength(255);

                entity.Property(e => e.Value).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.VendorId)
                    .IsRequired()
                    .HasColumnName("VendorID")
                    .HasMaxLength(15);
            });

            modelBuilder.Entity<PoabstractReceived>(entity =>
            {
                entity.HasKey(e => e.Ponumber)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("POAbstractReceived");

                entity.Property(e => e.Ponumber).HasColumnName("PONumber");

                entity.Property(e => e.BillingAddress).HasMaxLength(255);

                entity.Property(e => e.BranchForumCode).HasMaxLength(6);

                entity.Property(e => e.CreationTime).HasColumnType("datetime");

                entity.Property(e => e.CustomerId)
                    .HasColumnName("CustomerID")
                    .HasMaxLength(15);

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.ForumCode).HasMaxLength(20);

                entity.Property(e => e.Podate)
                    .HasColumnName("PODate")
                    .HasColumnType("datetime");

                entity.Property(e => e.Poprefix)
                    .HasColumnName("POPrefix")
                    .HasMaxLength(50);

                entity.Property(e => e.Poreference).HasColumnName("POReference");

                entity.Property(e => e.RequiredDate).HasColumnType("datetime");

                entity.Property(e => e.Salesmanid)
                    .HasColumnName("SALESMANID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.Salesmanname)
                    .HasColumnName("SALESMANNAME")
                    .HasMaxLength(200);

                entity.Property(e => e.ShippingAddress).HasMaxLength(255);

                entity.Property(e => e.Status).HasDefaultValueSql("(0)");

                entity.Property(e => e.Value).HasColumnType("decimal(18, 6)");
            });

            modelBuilder.Entity<ProductCategorization>(entity =>
            {
                entity.HasKey(e => e.CategorizationName);

                entity.Property(e => e.CategorizationName)
                    .HasMaxLength(255)
                    .ValueGeneratedNever();

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Id)
                    .HasColumnName("ID")
                    .ValueGeneratedOnAdd();
            });

            modelBuilder.Entity<Properties>(entity =>
            {
                entity.HasKey(e => e.PropertyId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.PropertyName)
                    .HasName("IX_Properties")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.PropertyId).HasColumnName("PropertyID");

                entity.Property(e => e.CreationDate).HasColumnType("datetime");

                entity.Property(e => e.PropertyName)
                    .IsRequired()
                    .HasColumnName("Property_Name")
                    .HasMaxLength(255);
            });

            modelBuilder.Entity<QueryFields>(entity =>
            {
                entity.HasKey(e => e.Id)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.Id).HasColumnName("ID");

                entity.Property(e => e.Delimiter)
                    .HasMaxLength(1)
                    .IsUnicode(false);

                entity.Property(e => e.DisplayField).HasMaxLength(50);

                entity.Property(e => e.DisplayName).HasMaxLength(50);

                entity.Property(e => e.FieldName)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.HasLookUp).HasDefaultValueSql("(0)");

                entity.Property(e => e.KeyField).HasMaxLength(50);

                entity.Property(e => e.LookUpTable).HasMaxLength(50);

                entity.Property(e => e.TableId).HasColumnName("TableID");
            });

            modelBuilder.Entity<QueryParams2>(entity =>
            {
                entity.HasKey(e => e.Values);

                entity.Property(e => e.Values)
                    .HasMaxLength(50)
                    .ValueGeneratedNever();
            });

            modelBuilder.Entity<QueryTables>(entity =>
            {
                entity.HasKey(e => e.Id)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.Id).HasColumnName("ID");

                entity.Property(e => e.TableName)
                    .IsRequired()
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<QuotationAbstract>(entity =>
            {
                entity.HasKey(e => e.QuotationId);

                entity.Property(e => e.QuotationId).HasColumnName("QuotationID");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.Gstflag).HasColumnName("GSTFlag");

                entity.Property(e => e.LastModifiedDate).HasColumnType("datetime");

                entity.Property(e => e.ModifiedUser).HasMaxLength(50);

                entity.Property(e => e.Prefix).HasMaxLength(50);

                entity.Property(e => e.QuotationDate).HasColumnType("datetime");

                entity.Property(e => e.QuotationLevel).HasDefaultValueSql("(null)");

                entity.Property(e => e.QuotationName).HasMaxLength(50);

                entity.Property(e => e.QuotationSubType).HasDefaultValueSql("(null)");

                entity.Property(e => e.Uomconversion)
                    .HasColumnName("UOMConversion")
                    .HasDefaultValueSql("(null)");

                entity.Property(e => e.UserName).HasMaxLength(50);

                entity.Property(e => e.ValidFromDate).HasColumnType("datetime");

                entity.Property(e => e.ValidToDate).HasColumnType("datetime");
            });

            modelBuilder.Entity<ReceivedCustomers>(entity =>
            {
                entity.HasKey(e => e.Id)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.Id).HasColumnName("ID");

                entity.Property(e => e.AlternateName)
                    .HasColumnName("Alternate_Name")
                    .HasMaxLength(100);

                entity.Property(e => e.Area).HasMaxLength(50);

                entity.Property(e => e.Awareness).HasMaxLength(4000);

                entity.Property(e => e.Beat).HasMaxLength(128);

                entity.Property(e => e.BillingAddress).HasMaxLength(255);

                entity.Property(e => e.BranchForumCode).HasMaxLength(6);

                entity.Property(e => e.ChannelType).HasMaxLength(128);

                entity.Property(e => e.ChannelType1)
                    .HasColumnName("Channel_type")
                    .HasMaxLength(500);

                entity.Property(e => e.City).HasMaxLength(50);

                entity.Property(e => e.CityStdcode)
                    .HasColumnName("CitySTDCode")
                    .HasMaxLength(50);

                entity.Property(e => e.CollectedPoints).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.CompanyName)
                    .HasColumnName("Company_Name")
                    .HasMaxLength(128);

                entity.Property(e => e.ContactPerson).HasMaxLength(255);

                entity.Property(e => e.Country).HasMaxLength(50);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.CreditLimit).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.CreditTerm).HasMaxLength(50);

                entity.Property(e => e.Cst)
                    .HasColumnName("CST")
                    .HasMaxLength(50);

                entity.Property(e => e.CustomerCategory).HasMaxLength(50);

                entity.Property(e => e.CustomerId)
                    .HasColumnName("CustomerID")
                    .HasMaxLength(15);

                entity.Property(e => e.CustomerPassword)
                    .HasColumnName("Customer_Password")
                    .HasMaxLength(20);

                entity.Property(e => e.District).HasMaxLength(100);

                entity.Property(e => e.Dlnumber20)
                    .HasColumnName("DLNumber20")
                    .HasMaxLength(100);

                entity.Property(e => e.Dlnumber21)
                    .HasColumnName("DLNumber21")
                    .HasMaxLength(50);

                entity.Property(e => e.Dob)
                    .HasColumnName("DOB")
                    .HasColumnType("datetime");

                entity.Property(e => e.Email)
                    .HasColumnName("EMail")
                    .HasMaxLength(50);

                entity.Property(e => e.Fax).HasMaxLength(100);

                entity.Property(e => e.Field1).HasMaxLength(255);

                entity.Property(e => e.Field10).HasMaxLength(255);

                entity.Property(e => e.Field11).HasMaxLength(255);

                entity.Property(e => e.Field12).HasMaxLength(255);

                entity.Property(e => e.Field13).HasMaxLength(255);

                entity.Property(e => e.Field2).HasMaxLength(255);

                entity.Property(e => e.Field3).HasMaxLength(255);

                entity.Property(e => e.Field4).HasMaxLength(255);

                entity.Property(e => e.Field5).HasMaxLength(255);

                entity.Property(e => e.Field6).HasMaxLength(255);

                entity.Property(e => e.Field7).HasMaxLength(255);

                entity.Property(e => e.Field8).HasMaxLength(255);

                entity.Property(e => e.Field9).HasMaxLength(255);

                entity.Property(e => e.FirstName).HasMaxLength(200);

                entity.Property(e => e.ForumCode).HasMaxLength(40);

                entity.Property(e => e.LoyaltyType)
                    .HasColumnName("Loyalty_Type")
                    .HasMaxLength(500);

                entity.Property(e => e.MembershipCode).HasMaxLength(100);

                entity.Property(e => e.Menu).HasMaxLength(500);

                entity.Property(e => e.MerchandiseType).HasMaxLength(2000);

                entity.Property(e => e.MobileNumber).HasMaxLength(100);

                entity.Property(e => e.Occupation).HasMaxLength(100);

                entity.Property(e => e.Omslock)
                    .HasColumnName("OMSLock")
                    .HasMaxLength(500);

                entity.Property(e => e.OutletType)
                    .HasColumnName("Outlet_type")
                    .HasMaxLength(500);

                entity.Property(e => e.Phone).HasMaxLength(50);

                entity.Property(e => e.PinCode).HasMaxLength(50);

                entity.Property(e => e.Potential).HasMaxLength(100);

                entity.Property(e => e.Rcsid)
                    .HasColumnName("RCSID")
                    .HasMaxLength(100);

                entity.Property(e => e.ReferredBy).HasMaxLength(100);

                entity.Property(e => e.Residence).HasMaxLength(100);

                entity.Property(e => e.RetailCategory).HasMaxLength(250);

                entity.Property(e => e.Salutation).HasMaxLength(100);

                entity.Property(e => e.SecondName).HasMaxLength(200);

                entity.Property(e => e.SegmentId).HasColumnName("SegmentID");

                entity.Property(e => e.SequenceNo).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ShippingAddress).HasMaxLength(255);

                entity.Property(e => e.State).HasMaxLength(50);

                entity.Property(e => e.SubChannel).HasMaxLength(100);

                entity.Property(e => e.TinNumber)
                    .HasColumnName("TIN_NUMBER")
                    .HasMaxLength(100);

                entity.Property(e => e.Tngst)
                    .HasColumnName("TNGST")
                    .HasMaxLength(50);

                entity.Property(e => e.UpdateStatus).HasMaxLength(255);

                entity.Property(e => e.UserName)
                    .HasColumnName("User_Name")
                    .HasMaxLength(500);
            });

            modelBuilder.Entity<ReceivedSegments>(entity =>
            {
                entity.HasKey(e => e.SegmentId);

                entity.Property(e => e.SegmentId).HasColumnName("SegmentID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.BranchForumCode).HasMaxLength(400);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Description).HasMaxLength(255);

                entity.Property(e => e.ModifiedDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.ParentCode).HasMaxLength(255);

                entity.Property(e => e.SegmentCode).HasMaxLength(255);

                entity.Property(e => e.SegmentName).HasMaxLength(255);
            });

            modelBuilder.Entity<RejectionReason>(entity =>
            {
                entity.HasKey(e => e.MessageId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.Message)
                    .HasName("IX_RejectionReason")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.MessageId).HasColumnName("MessageID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Message)
                    .IsRequired()
                    .HasMaxLength(255);
            });

            modelBuilder.Entity<ReportData>(entity =>
            {
                entity.Property(e => e.Id)
                    .HasColumnName("ID")
                    .ValueGeneratedNever();

                entity.Property(e => e.Action).HasDefaultValueSql("(0)");

                entity.Property(e => e.ActionData).HasMaxLength(100);

                entity.Property(e => e.ColumnWidth).HasMaxLength(255);

                entity.Property(e => e.Description).HasMaxLength(50);

                entity.Property(e => e.DetailCommand).HasDefaultValueSql("(0)");

                entity.Property(e => e.Footer).HasMaxLength(255);

                entity.Property(e => e.FormatId)
                    .HasColumnName("FormatID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.ForwardParam).HasDefaultValueSql("(0)");

                entity.Property(e => e.Header).HasMaxLength(255);

                entity.Property(e => e.Image).HasDefaultValueSql("(1)");

                entity.Property(e => e.Inactive).HasDefaultValueSql("(0)");

                entity.Property(e => e.KeyType).HasDefaultValueSql("(3)");

                entity.Property(e => e.Node)
                    .IsRequired()
                    .HasMaxLength(400);

                entity.Property(e => e.Parent).HasDefaultValueSql("(0)");

                entity.Property(e => e.SelectedImage).HasDefaultValueSql("(1)");

                entity.Property(e => e.SubTotalLabel).HasMaxLength(50);

                entity.Property(e => e.SubTotals).HasMaxLength(255);
            });

            modelBuilder.Entity<Reports>(entity =>
            {
                entity.HasKey(e => e.ReportId);

                entity.Property(e => e.ReportId).HasColumnName("ReportID");

                entity.Property(e => e.CompanyId)
                    .HasColumnName("CompanyID")
                    .HasMaxLength(50);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.ParameterId).HasColumnName("ParameterID");

                entity.Property(e => e.ReportDate).HasColumnType("datetime");

                entity.Property(e => e.ReportName).HasMaxLength(250);
            });

            modelBuilder.Entity<ReportsToUpload>(entity =>
            {
                entity.HasKey(e => e.ReportId);

                entity.ToTable("Reports_To_Upload");

                entity.HasIndex(e => e.ReportName)
                    .HasName("IX_Reports_To_Upload");

                entity.Property(e => e.ReportId).HasColumnName("ReportID");

                entity.Property(e => e.AbstractData).HasMaxLength(255);

                entity.Property(e => e.AliasActionData).HasMaxLength(100);

                entity.Property(e => e.CompanyId).HasColumnName("CompanyID");

                entity.Property(e => e.GenOrderBy).HasDefaultValueSql("(0)");

                entity.Property(e => e.Gud)
                    .HasColumnName("GUD")
                    .HasColumnType("datetime");

                entity.Property(e => e.LastUploadDate).HasColumnType("datetime");

                entity.Property(e => e.ParameterId)
                    .HasColumnName("ParameterID")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.ReportDataId).HasColumnName("ReportDataID");

                entity.Property(e => e.ReportName)
                    .IsRequired()
                    .HasMaxLength(128);

                entity.Property(e => e.XmlreportCode)
                    .HasColumnName("XMLReportCode")
                    .HasMaxLength(200);
            });

            modelBuilder.Entity<Salesman>(entity =>
            {
                entity.HasKey(e => e.SalesmanId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.SalesmanName)
                    .HasName("IX_Salesman")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.SalesmanId).HasColumnName("SalesmanID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.Address).HasMaxLength(255);

                entity.Property(e => e.Commission)
                    .HasColumnName("commission")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.MobileNumber).HasMaxLength(20);

                entity.Property(e => e.ModifiedDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.ResidentialNumber).HasMaxLength(20);

                entity.Property(e => e.SalesManCode).HasMaxLength(15);

                entity.Property(e => e.SalesmanName)
                    .IsRequired()
                    .HasColumnName("Salesman_Name")
                    .HasMaxLength(50);

                entity.Property(e => e.SkillLevel).HasDefaultValueSql("((0))");

                entity.Property(e => e.Smsalert).HasColumnName("SMSAlert");
            });

            modelBuilder.Entity<SalesPortalIplist>(entity =>
            {
                entity.HasKey(e => e.Ipaddress);

                entity.ToTable("SalesPortalIPList");

                entity.Property(e => e.Ipaddress)
                    .HasColumnName("IPAddress")
                    .HasMaxLength(20)
                    .ValueGeneratedNever();
            });

            modelBuilder.Entity<Salesstaff>(entity =>
            {
                entity.HasKey(e => e.StaffId);

                entity.ToTable("salesstaff");

                entity.Property(e => e.StaffId).HasColumnName("Staff_ID");

                entity.Property(e => e.Address).HasMaxLength(510);

                entity.Property(e => e.Commission).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Phone).HasMaxLength(100);

                entity.Property(e => e.StaffName)
                    .HasColumnName("Staff_Name")
                    .HasMaxLength(100);
            });

            modelBuilder.Entity<Schemes>(entity =>
            {
                entity.HasKey(e => e.SchemeId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.SchemeName)
                    .HasName("IX_Schemes")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.SchemeId).HasColumnName("SchemeID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.Approved).HasDefaultValueSql("(0)");

                entity.Property(e => e.BudgetedAmount)
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.FromHour).HasColumnType("datetime");

                entity.Property(e => e.Message).HasMaxLength(255);

                entity.Property(e => e.ModifiedDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.PaymentMode).HasMaxLength(255);

                entity.Property(e => e.Promptonly).HasDefaultValueSql("(0)");

                entity.Property(e => e.SchemeDescription).HasMaxLength(255);

                entity.Property(e => e.SchemeName)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.ToHour).HasColumnType("datetime");

                entity.Property(e => e.ValidFrom).HasColumnType("datetime");

                entity.Property(e => e.ValidTo).HasColumnType("datetime");
            });

            modelBuilder.Entity<SchemesRec>(entity =>
            {
                entity.HasKey(e => e.SchemeId)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("Schemes_rec");

                entity.HasIndex(e => e.SchemeName)
                    .HasName("IX_Schemes_rec")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.SchemeId).HasColumnName("SchemeID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.BudgetedAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.CompanyId)
                    .HasColumnName("CompanyID")
                    .HasMaxLength(100);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Flag).HasDefaultValueSql("(1)");

                entity.Property(e => e.ForumCode).HasMaxLength(100);

                entity.Property(e => e.FromHour).HasColumnType("datetime");

                entity.Property(e => e.Message).HasMaxLength(255);

                entity.Property(e => e.ModifiedDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.PaymentMode).HasMaxLength(255);

                entity.Property(e => e.Promptonly).HasDefaultValueSql("(0)");

                entity.Property(e => e.SchemeDescription).HasMaxLength(255);

                entity.Property(e => e.SchemeName)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.ToHour).HasColumnType("datetime");

                entity.Property(e => e.ValidFrom).HasColumnType("datetime");

                entity.Property(e => e.ValidTo).HasColumnType("datetime");
            });

            modelBuilder.Entity<ServiceTypeMaster>(entity =>
            {
                entity.HasKey(e => e.ServiceName);

                entity.Property(e => e.ServiceName)
                    .HasMaxLength(255)
                    .ValueGeneratedNever();

                entity.Property(e => e.Active).HasDefaultValueSql("((1))");

                entity.Property(e => e.Code).ValueGeneratedOnAdd();

                entity.Property(e => e.DateOfCreation)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.InputAccId).HasColumnName("InputAccID");

                entity.Property(e => e.OutputAccId).HasColumnName("OutputAccID");

                entity.Property(e => e.ServiceAccountCode).HasMaxLength(50);
            });

            modelBuilder.Entity<Soabstract>(entity =>
            {
                entity.HasKey(e => e.Sonumber)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("SOAbstract");

                entity.HasIndex(e => e.Sodate);

                entity.Property(e => e.Sonumber).HasColumnName("SONumber");

                entity.Property(e => e.BeatId).HasDefaultValueSql("(0)");

                entity.Property(e => e.BillingAddress).HasMaxLength(255);

                entity.Property(e => e.BranchCode).HasMaxLength(15);

                entity.Property(e => e.CancelDate).HasColumnType("datetime");

                entity.Property(e => e.Cancelusername).HasMaxLength(50);

                entity.Property(e => e.ClientId).HasColumnName("ClientID");

                entity.Property(e => e.CreationTime)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.CustomerId)
                    .HasColumnName("CustomerID")
                    .HasMaxLength(15);

                entity.Property(e => e.DeliveryDate).HasColumnType("datetime");

                entity.Property(e => e.DocSerialType).HasMaxLength(100);

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.DocumentReference).HasMaxLength(510);

                entity.Property(e => e.ForumSc).HasColumnName("ForumSC");

                entity.Property(e => e.GroupId)
                    .HasColumnName("GroupID")
                    .HasMaxLength(1000);

                entity.Property(e => e.Gstflag).HasColumnName("GSTFlag");

                entity.Property(e => e.Gstin)
                    .HasColumnName("GSTIN")
                    .HasMaxLength(30);

                entity.Property(e => e.OriginalSo).HasColumnName("OriginalSO");

                entity.Property(e => e.PaymentDate).HasColumnType("datetime");

                entity.Property(e => e.PodocReference)
                    .HasColumnName("PODocReference")
                    .HasMaxLength(255);

                entity.Property(e => e.Poreference)
                    .HasColumnName("POReference")
                    .HasMaxLength(255);

                entity.Property(e => e.RefNumber).HasMaxLength(255);

                entity.Property(e => e.Remarks).HasMaxLength(255);

                entity.Property(e => e.SalesmanId).HasColumnName("SalesmanID");

                entity.Property(e => e.ShippingAddress).HasMaxLength(255);

                entity.Property(e => e.Sodate)
                    .HasColumnName("SODate")
                    .HasColumnType("datetime");

                entity.Property(e => e.SupervisorId).HasColumnName("SupervisorID");

                entity.Property(e => e.TaxOnMrp).HasColumnName("TaxOnMRP");

                entity.Property(e => e.UserName).HasMaxLength(100);

                entity.Property(e => e.Value).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.VattaxAmount)
                    .HasColumnName("VATTaxAmount")
                    .HasColumnType("decimal(18, 6)");
            });

            modelBuilder.Entity<SoabstractReceived>(entity =>
            {
                entity.HasKey(e => e.Sonumber)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("SOAbstractReceived");

                entity.Property(e => e.Sonumber).HasColumnName("SONumber");

                entity.Property(e => e.BillingAddress).HasMaxLength(255);

                entity.Property(e => e.CreationTime).HasColumnType("datetime");

                entity.Property(e => e.DeliveryDate).HasColumnType("datetime");

                entity.Property(e => e.DocumentId)
                    .HasColumnName("DocumentID")
                    .HasMaxLength(50);

                entity.Property(e => e.ForumCode).HasMaxLength(20);

                entity.Property(e => e.Poreference)
                    .HasColumnName("POReference")
                    .HasMaxLength(255);

                entity.Property(e => e.RefNumber).HasMaxLength(50);

                entity.Property(e => e.ShippingAddress).HasMaxLength(255);

                entity.Property(e => e.Sodate)
                    .HasColumnName("SODate")
                    .HasColumnType("datetime");

                entity.Property(e => e.Status).HasDefaultValueSql("(0)");

                entity.Property(e => e.Value).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.VendorId)
                    .HasColumnName("VendorID")
                    .HasMaxLength(15);
            });

            modelBuilder.Entity<SoldAs>(entity =>
            {
                entity.HasKey(e => e.SoldAs1);

                entity.Property(e => e.SoldAs1)
                    .HasColumnName("SoldAs")
                    .HasMaxLength(50)
                    .ValueGeneratedNever();
            });

            modelBuilder.Entity<SpecialCategory>(entity =>
            {
                entity.HasKey(e => e.SpecialCatCode)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("Special_Category");

                entity.HasIndex(e => e.Description)
                    .HasName("Unique_splcat_Desc")
                    .IsUnique();

                entity.Property(e => e.SpecialCatCode).HasColumnName("Special_Cat_Code");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Description).HasMaxLength(255);

                entity.Property(e => e.SchemeId)
                    .HasColumnName("SchemeID")
                    .HasDefaultValueSql("(0)");
            });

            modelBuilder.Entity<State>(entity =>
            {
                entity.HasKey(e => e.StateId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.State1)
                    .HasName("IX_State")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.StateId).HasColumnName("StateID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.State1)
                    .IsRequired()
                    .HasColumnName("State")
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<StateCode>(entity =>
            {
                entity.HasKey(e => e.StateId);

                entity.Property(e => e.StateId)
                    .HasColumnName("StateID")
                    .ValueGeneratedNever();

                entity.Property(e => e.CensusCode).HasMaxLength(255);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.ForumStateCode)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.StateName)
                    .IsRequired()
                    .HasMaxLength(255);
            });

            modelBuilder.Entity<StockAdjustmentReason>(entity =>
            {
                entity.HasKey(e => e.MessageId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.Message)
                    .HasName("IX_StockAdjustmentReason")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.MessageId).HasColumnName("MessageID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Message)
                    .IsRequired()
                    .HasMaxLength(255);
            });

            modelBuilder.Entity<StockRequestAbstractReceived>(entity =>
            {
                entity.HasKey(e => e.StkReqNumber);

                entity.ToTable("Stock_Request_Abstract_Received");

                entity.Property(e => e.StkReqNumber).HasColumnName("STK_REQ_Number");

                entity.Property(e => e.BillingAddress).HasMaxLength(255);

                entity.Property(e => e.CreationTime)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.CustomerId)
                    .HasColumnName("CustomerID")
                    .HasMaxLength(15);

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.ForumCode).HasMaxLength(20);

                entity.Property(e => e.RequiredDate).HasColumnType("datetime");

                entity.Property(e => e.ShippingAddress).HasMaxLength(255);

                entity.Property(e => e.Status).HasDefaultValueSql("(0)");

                entity.Property(e => e.StkReqDate)
                    .HasColumnName("STK_REQ_Date")
                    .HasColumnType("datetime");

                entity.Property(e => e.StkReqPrefix)
                    .HasColumnName("STK_REQ_Prefix")
                    .HasMaxLength(50);

                entity.Property(e => e.StkReqReference).HasColumnName("STK_REQ_Reference");

                entity.Property(e => e.Value).HasColumnType("decimal(18, 6)");
            });

            modelBuilder.Entity<StockTransferInAbstract>(entity =>
            {
                entity.HasKey(e => e.DocSerial);

                entity.Property(e => e.Address).HasMaxLength(255);

                entity.Property(e => e.CancelUser).HasMaxLength(50);

                entity.Property(e => e.CancellationDate).HasColumnType("datetime");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DocPrefix).HasMaxLength(50);

                entity.Property(e => e.DocReference).HasMaxLength(255);

                entity.Property(e => e.DocumentDate).HasColumnType("datetime");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.Gstflag).HasColumnName("GSTFlag");

                entity.Property(e => e.Gstin)
                    .HasColumnName("GSTIN")
                    .HasMaxLength(15);

                entity.Property(e => e.NetValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Reference).HasMaxLength(255);

                entity.Property(e => e.ReferenceSerial).HasMaxLength(255);

                entity.Property(e => e.Remarks).HasMaxLength(255);

                entity.Property(e => e.StiLrNo)
                    .HasColumnName("Sti_lr_no")
                    .HasMaxLength(100);

                entity.Property(e => e.StiNarration)
                    .HasColumnName("Sti_narration")
                    .HasMaxLength(100);

                entity.Property(e => e.StiRecDate)
                    .HasColumnName("Sti_Rec_date")
                    .HasColumnType("datetime");

                entity.Property(e => e.StiTranInfo)
                    .HasColumnName("Sti_tran_info")
                    .HasMaxLength(100);

                entity.Property(e => e.TaxAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.TaxOnMrp)
                    .HasColumnName("TaxOnMRP")
                    .HasDefaultValueSql("(0)");

                entity.Property(e => e.UserName).HasMaxLength(50);

                entity.Property(e => e.VatTaxAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.WareHouseId)
                    .IsRequired()
                    .HasColumnName("WareHouseID")
                    .HasMaxLength(25);
            });

            modelBuilder.Entity<StockTransferOutAbstract>(entity =>
            {
                entity.HasKey(e => e.DocSerial);

                entity.Property(e => e.Address).HasMaxLength(255);

                entity.Property(e => e.CancelRemarks).HasMaxLength(255);

                entity.Property(e => e.CancelUser).HasMaxLength(50);

                entity.Property(e => e.CancellationDate).HasColumnType("datetime");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DocPrefix).HasMaxLength(50);

                entity.Property(e => e.DocumentDate).HasColumnType("datetime");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.Gstflag).HasColumnName("GSTFlag");

                entity.Property(e => e.NetValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Reference).HasMaxLength(255);

                entity.Property(e => e.StoLrNo)
                    .HasColumnName("Sto_lr_no")
                    .HasMaxLength(100);

                entity.Property(e => e.StoNarration)
                    .HasColumnName("Sto_narration")
                    .HasMaxLength(100);

                entity.Property(e => e.StoTranInfo)
                    .HasColumnName("Sto_tran_info")
                    .HasMaxLength(100);

                entity.Property(e => e.StodocIdref)
                    .HasColumnName("STODocIDRef")
                    .HasMaxLength(50);

                entity.Property(e => e.Stoidref).HasColumnName("STOIDRef");

                entity.Property(e => e.TaxAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.TaxOnMrp).HasColumnName("TaxOnMRP");

                entity.Property(e => e.UserName).HasMaxLength(50);

                entity.Property(e => e.VatTaxAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.WareHouseId)
                    .IsRequired()
                    .HasColumnName("WareHouseID")
                    .HasMaxLength(25);
            });

            modelBuilder.Entity<StockTransferOutAbstractReceived>(entity =>
            {
                entity.HasKey(e => e.DocSerial);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DocumentDate).HasColumnType("datetime");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.ForumCode)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.NetValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.OriginalId)
                    .IsRequired()
                    .HasColumnName("OriginalID")
                    .HasMaxLength(25);

                entity.Property(e => e.Reference).HasMaxLength(255);

                entity.Property(e => e.TaxAmount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.WareHouseId)
                    .HasColumnName("WareHouseID")
                    .HasMaxLength(25);
            });

            modelBuilder.Entity<TargetMeasure>(entity =>
            {
                entity.HasKey(e => e.MeasureId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.Description)
                    .HasName("IX_TargetMeasure")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.MeasureId).HasColumnName("MeasureID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.Description).HasMaxLength(128);
            });

            modelBuilder.Entity<TargetPeriod>(entity =>
            {
                entity.HasKey(e => e.PeriodId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.Period)
                    .HasName("UQ__TargetPeriod__54F67D98")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.PeriodId).HasColumnName("PeriodID");

                entity.Property(e => e.Period)
                    .IsRequired()
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<Tax>(entity =>
            {
                entity.HasKey(e => e.TaxCode)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.TaxDescription)
                    .HasName("IX_Tax")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.TaxCode).HasColumnName("Tax_Code");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.CsTaxCode).HasColumnName("CS_TaxCode");

                entity.Property(e => e.CstPercentage)
                    .HasColumnName("CST_Percentage")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.CstapplicableOn)
                    .HasColumnName("CSTApplicableOn")
                    .HasDefaultValueSql("(1)");

                entity.Property(e => e.CstpartOff)
                    .HasColumnName("CSTPartOff")
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(100)");

                entity.Property(e => e.EffectiveFrom).HasColumnType("datetime");

                entity.Property(e => e.Gstflag).HasColumnName("GSTFlag");

                entity.Property(e => e.LstapplicableOn)
                    .HasColumnName("LSTApplicableOn")
                    .HasDefaultValueSql("(1)");

                entity.Property(e => e.LstpartOff)
                    .HasColumnName("LSTPartOff")
                    .HasColumnType("decimal(18, 6)")
                    .HasDefaultValueSql("(100)");

                entity.Property(e => e.Percentage).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.TaxDescription)
                    .IsRequired()
                    .HasColumnName("Tax_Description")
                    .HasMaxLength(255);
            });

            modelBuilder.Entity<TaxApplicableOn>(entity =>
            {
                entity.HasKey(e => e.ApplicableOnCode);

                entity.Property(e => e.ApplicableOnCode).ValueGeneratedNever();

                entity.Property(e => e.ApplicableOnDesc)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");
            });

            modelBuilder.Entity<TaxStateType>(entity =>
            {
                entity.Property(e => e.TaxStateTypeId)
                    .HasColumnName("TaxStateTypeID")
                    .ValueGeneratedNever();

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.TaxStateTypeName)
                    .IsRequired()
                    .HasMaxLength(20);
            });

            modelBuilder.Entity<TblMErpAlltaxtype>(entity =>
            {
                entity.HasKey(e => e.Taxtype);

                entity.ToTable("tbl_mERP_ALLTaxtype");

                entity.Property(e => e.Taxtype)
                    .HasMaxLength(50)
                    .ValueGeneratedNever();

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.TaxId).HasColumnName("TaxID");
            });

            modelBuilder.Entity<TblMErpConfigAbstract>(entity =>
            {
                entity.HasKey(e => e.ScreenCode);

                entity.ToTable("tbl_mERP_ConfigAbstract");

                entity.Property(e => e.ScreenCode)
                    .HasMaxLength(255)
                    .ValueGeneratedNever();

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Description).HasMaxLength(255);

                entity.Property(e => e.Flag).HasDefaultValueSql("(1)");

                entity.Property(e => e.ModifiedDate).HasColumnType("datetime");

                entity.Property(e => e.ScreenName)
                    .IsRequired()
                    .HasMaxLength(255);
            });

            modelBuilder.Entity<TblMerpSurveyChannelMapping>(entity =>
            {
                entity.HasKey(e => new { e.SurveyId, e.ChannelType, e.OutletType, e.LoyaltyProgram });

                entity.ToTable("tbl_merp_SurveyChannelMapping");

                entity.Property(e => e.SurveyId).HasColumnName("SurveyID");

                entity.Property(e => e.ChannelType).HasMaxLength(255);

                entity.Property(e => e.OutletType).HasMaxLength(255);

                entity.Property(e => e.LoyaltyProgram).HasMaxLength(255);
            });

            modelBuilder.Entity<TblMerpSurveyDsmapping>(entity =>
            {
                entity.HasKey(e => new { e.SurveyId, e.Dstype });

                entity.ToTable("tbl_merp_SurveyDSMapping");

                entity.Property(e => e.SurveyId).HasColumnName("SurveyID");

                entity.Property(e => e.Dstype)
                    .HasColumnName("DSType")
                    .HasMaxLength(100);
            });

            modelBuilder.Entity<TblMerpSurveyMaster>(entity =>
            {
                entity.HasKey(e => e.SurveyId);

                entity.ToTable("tbl_merp_SurveyMaster");

                entity.Property(e => e.SurveyId)
                    .HasColumnName("SurveyID")
                    .ValueGeneratedNever();

                entity.Property(e => e.CreationDate).HasColumnType("datetime");

                entity.Property(e => e.EffectiveFrom).HasColumnType("datetime");

                entity.Property(e => e.SurveyCode).HasMaxLength(50);

                entity.Property(e => e.SurveyDescription).HasMaxLength(50);

                entity.Property(e => e.SurveyType)
                    .HasMaxLength(1)
                    .IsUnicode(false);
            });

            modelBuilder.Entity<TblMerpSurveyProductMapping>(entity =>
            {
                entity.HasKey(e => new { e.SurveyId, e.ProductId, e.ProductName, e.ProductSequence });

                entity.ToTable("tbl_merp_SurveyProductMapping");

                entity.Property(e => e.SurveyId).HasColumnName("SurveyID");

                entity.Property(e => e.ProductId)
                    .HasColumnName("ProductID")
                    .HasMaxLength(10);

                entity.Property(e => e.ProductName).HasMaxLength(50);
            });

            modelBuilder.Entity<TblMerpSurveyQuestionAnswerMapping>(entity =>
            {
                entity.HasKey(e => new { e.SurveyId, e.QuestionId, e.AnswerId });

                entity.ToTable("tbl_merp_SurveyQuestionAnswerMapping");

                entity.Property(e => e.SurveyId).HasColumnName("SurveyID");

                entity.Property(e => e.QuestionId).HasColumnName("QuestionID");

                entity.Property(e => e.AnswerId).HasColumnName("AnswerID");

                entity.Property(e => e.AnswerDesc).HasMaxLength(50);

                entity.Property(e => e.AnswerValue).HasMaxLength(50);
            });

            modelBuilder.Entity<TblMerpSurveyQuestionMapping>(entity =>
            {
                entity.HasKey(e => new { e.SurveyId, e.QuestionId });

                entity.ToTable("tbl_merp_SurveyQuestionMapping");

                entity.Property(e => e.SurveyId).HasColumnName("SurveyID");

                entity.Property(e => e.QuestionId).HasColumnName("QuestionID");

                entity.Property(e => e.QuestionDesc).HasMaxLength(50);

                entity.Property(e => e.QuestionType).HasMaxLength(10);
            });

            modelBuilder.Entity<TblMErpZone>(entity =>
            {
                entity.HasKey(e => e.ZoneId)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("tbl_mERP_Zone");

                entity.HasIndex(e => e.ZoneName)
                    .HasName("IX_Zone")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.ZoneId).HasColumnName("ZoneID");

                entity.Property(e => e.Active).HasDefaultValueSql("((1))");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.ModifiedDate).HasColumnType("datetime");

                entity.Property(e => e.ZoneName)
                    .IsRequired()
                    .HasMaxLength(255);
            });

            modelBuilder.Entity<Uom>(entity =>
            {
                entity.HasKey(e => e.Uom1)
                    .ForSqlServerIsClustered(false);

                entity.ToTable("UOM");

                entity.HasIndex(e => e.Description)
                    .HasName("IX_UOM")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.Uom1).HasColumnName("UOM");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Description).HasMaxLength(255);
            });

            modelBuilder.Entity<UpgradeTables>(entity =>
            {
                entity.HasKey(e => e.TableId);

                entity.HasIndex(e => e.TableName)
                    .HasName("IX_UpgradeTables")
                    .IsUnique();

                entity.Property(e => e.TableId).HasColumnName("TableID");

                entity.Property(e => e.TableName)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.UpgradeCriteria).HasMaxLength(4000);
            });

            modelBuilder.Entity<Users>(entity =>
            {
                entity.HasKey(e => e.UserName)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.UserName)
                    .HasMaxLength(50)
                    .ValueGeneratedNever();

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.GroupName)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.Password).HasMaxLength(50);
            });

            modelBuilder.Entity<Van>(entity =>
            {
                entity.HasKey(e => e.Van1);

                entity.Property(e => e.Van1)
                    .HasColumnName("Van")
                    .HasMaxLength(50)
                    .ValueGeneratedNever();

                entity.Property(e => e.ReadyStockSalesVan).HasColumnName("ReadyStockSalesVAN");

                entity.Property(e => e.VanNumber)
                    .HasColumnName("Van_Number")
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<VanStatementAbstract>(entity =>
            {
                entity.HasKey(e => e.DocSerial);

                entity.HasIndex(e => e.DocumentId)
                    .HasName("IX_VanStatementAbstract");

                entity.Property(e => e.BeatId).HasColumnName("BeatID");

                entity.Property(e => e.CreationTime)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DocPrefix).HasMaxLength(50);

                entity.Property(e => e.DocumentDate).HasColumnType("datetime");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.DocumentValue).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.LoadingDate).HasColumnType("datetime");

                entity.Property(e => e.OriginalClientId).HasColumnName("OriginalClientID");

                entity.Property(e => e.SalesmanId).HasColumnName("SalesmanID");

                entity.Property(e => e.UserName).HasMaxLength(50);

                entity.Property(e => e.VanId)
                    .HasColumnName("VanID")
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<VanStatementDetail>(entity =>
            {
                entity.Property(e => e.Id).HasColumnName("ID");

                entity.Property(e => e.Amount).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.BatchCode).HasColumnName("Batch_Code");

                entity.Property(e => e.BatchNumber)
                    .HasColumnName("Batch_Number")
                    .HasMaxLength(128);

                entity.Property(e => e.Bfqty)
                    .HasColumnName("BFQty")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Ecp)
                    .HasColumnName("ECP")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.MrpperPack)
                    .HasColumnName("MRPPerPack")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.MultipleSchemeId)
                    .HasColumnName("MultipleSchemeID")
                    .HasMaxLength(255);

                entity.Property(e => e.Pending).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.ProductCode)
                    .IsRequired()
                    .HasColumnName("Product_Code")
                    .HasMaxLength(15);

                entity.Property(e => e.Ptr)
                    .HasColumnName("PTR")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Pts)
                    .HasColumnName("PTS")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.PurchasePrice).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Quantity).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.SalePrice).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.SpecialPrice).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.TransferQty).HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Uom).HasColumnName("UOM");

                entity.Property(e => e.Uomprice)
                    .HasColumnName("UOMPrice")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.Uomqty)
                    .HasColumnName("UOMQty")
                    .HasColumnType("decimal(18, 6)");

                entity.Property(e => e.VanTransferId).HasColumnName("VanTransferID");
            });

            modelBuilder.Entity<Vendors>(entity =>
            {
                entity.HasKey(e => e.VendorId)
                    .ForSqlServerIsClustered(false);

                entity.HasIndex(e => e.VendorName)
                    .HasName("IX_Vendors")
                    .IsUnique()
                    .ForSqlServerIsClustered();

                entity.Property(e => e.VendorId)
                    .HasColumnName("VendorID")
                    .HasMaxLength(15)
                    .ValueGeneratedNever();

                entity.Property(e => e.AccountId).HasColumnName("AccountID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.Address).HasMaxLength(255);

                entity.Property(e => e.AlternateCode).HasMaxLength(20);

                entity.Property(e => e.BillingStateId).HasColumnName("BillingStateID");

                entity.Property(e => e.CityId).HasColumnName("CityID");

                entity.Property(e => e.ContactPerson).HasMaxLength(50);

                entity.Property(e => e.CountryId).HasColumnName("CountryID");

                entity.Property(e => e.CreationDate)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.Cst)
                    .HasColumnName("CST")
                    .HasMaxLength(50);

                entity.Property(e => e.Email).HasMaxLength(50);

                entity.Property(e => e.Fax).HasMaxLength(50);

                entity.Property(e => e.Gstin)
                    .HasColumnName("GSTIN")
                    .HasMaxLength(15);

                entity.Property(e => e.Pannumber)
                    .HasColumnName("PANNumber")
                    .HasMaxLength(100);

                entity.Property(e => e.PayableTo)
                    .HasColumnName("Payable_To")
                    .HasMaxLength(256);

                entity.Property(e => e.Phone).HasMaxLength(50);

                entity.Property(e => e.ProductSupplied).HasMaxLength(255);

                entity.Property(e => e.SaleId).HasColumnName("SaleID");

                entity.Property(e => e.StateId).HasColumnName("StateID");

                entity.Property(e => e.TinNumber)
                    .HasColumnName("TIN_Number")
                    .HasMaxLength(50);

                entity.Property(e => e.Tngst)
                    .HasColumnName("TNGST")
                    .HasMaxLength(50);

                entity.Property(e => e.VendorName)
                    .IsRequired()
                    .HasColumnName("Vendor_Name")
                    .HasMaxLength(50);

                entity.Property(e => e.VendorRating).HasMaxLength(50);
            });

            modelBuilder.Entity<VoucherPrefix>(entity =>
            {
                entity.HasKey(e => e.TranId)
                    .ForSqlServerIsClustered(false);

                entity.Property(e => e.TranId)
                    .HasColumnName("TranID")
                    .HasMaxLength(50)
                    .ValueGeneratedNever();

                entity.Property(e => e.Prefix).HasMaxLength(10);
            });

            modelBuilder.Entity<WareHouse>(entity =>
            {
                entity.Property(e => e.WareHouseId)
                    .HasColumnName("WareHouseID")
                    .HasMaxLength(25)
                    .ValueGeneratedNever();

                entity.Property(e => e.AccountId).HasColumnName("AccountID");

                entity.Property(e => e.Active).HasDefaultValueSql("(1)");

                entity.Property(e => e.Address).HasMaxLength(255);

                entity.Property(e => e.BillingStateId).HasColumnName("BillingStateID");

                entity.Property(e => e.City).HasDefaultValueSql("(0)");

                entity.Property(e => e.Country).HasDefaultValueSql("(0)");

                entity.Property(e => e.ForumId)
                    .HasColumnName("ForumID")
                    .HasMaxLength(20);

                entity.Property(e => e.Gstin)
                    .HasColumnName("GSTIN")
                    .HasMaxLength(15);

                entity.Property(e => e.State).HasDefaultValueSql("(0)");

                entity.Property(e => e.TinNumber)
                    .HasColumnName("TIN_Number")
                    .HasMaxLength(50);

                entity.Property(e => e.WareHouseName)
                    .IsRequired()
                    .HasColumnName("WareHouse_Name")
                    .HasMaxLength(50);
            });
        }
    }
}
