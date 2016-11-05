CREATE OR REPLACE VIEW view_invoice AS
SELECT
  JIHdr_JInvoice_UID as HdrUID,
  JIHdr_DateInv_DT as DateInvoiced,
  JIHdr_DateShip_DT as DateShipped,
  JIHdr_DateOrd_DT as DateOrdered,
  JIHdr_POCust as CustomerPO,
  JIHdr_POInternal as InternalPO,
  JComp_Name as Company,
  CONCAT(JPers_NameFirst,' ',JPers_NameMiddle,' ',JPers_NameLast) as Person,
  JIHdr_ShipVia as ShipVIA,
  JIHdr_SalesAmt_d as SalesAmt,
  JIHdr_MiscAmt_d as MiscAmt,
  JIHdr_SalesTaxAmt_d as SalesTaxAmt,
  JIHdr_ShipAmt_d as ShipAmt,
  JIHdr_TotalAmt_d as TotalAmt,
  JIHdr_BillToAddr01 as BillingAddress1,
  JIHdr_BillToAddr02 as BillingAddress2,
  JIHdr_BillToAddr03 as BillingAddress3,
  JIHdr_BillToCity as BillingCity,
  JIHdr_BillToState as BillingState,
  JIHdr_BillToPostalCode as BillingPostalCode,
  JIHdr_BillToCountry as BillingCountry,

  JIHdr_ShipToAddr01 as ShippingAddress1,
  JIHdr_ShipToAddr02 as ShippingAddress2,
  JIHdr_ShipToAddr03 as ShippingAddress3,
  JIHdr_ShipToCity as ShippingCity,
  JIHdr_ShipToState as ShippingState,
  JIHdr_ShipToPostalCode as ShippingPostalCode,
  JIHdr_ShipToCountry as ShippingCountry,

  juser.JUser_Name as HdrCreatedBy,
  JIHdr_Created_DT as HdrCreated,
  juser2.JUser_Name as HdrModifiedBy,
  JIHdr_Modified_DT as HdrModified,
  JIHdr_Notes as InvoiceNotes,
  JIHdr_Terms as InvoiceTerms,

  JILin_JInvoiceLines_UID as LineUID,
  JProd_Name as Product,
  JILin_QtyOrd_d as QtyOrdered,
  JILin_QtyShip_d as QtyShipped,
  JILin_PrcExt_d as ExtPrice,
  juser2.JUser_Name as LineCreatedBy,
  JILin_Created_DT as LineCreated,
  juser.JUser_Name as LineModifiedBy,
  JILin_Modified_DT as LineModified,
  JILin_Desc as Description

FROM jinvoicelines
  LEFT JOIN jinvoice on jinvoice.JIHdr_JInvoice_UID=JILin_JInvoice_ID
  LEFT JOIN jcompany on JComp_JCompany_UID=JIHdr_JCompany_ID
  LEFT JOIN jperson on JPers_JPerson_UID=JIHdr_JPerson_ID
  LEFT JOIN jproduct on jproduct.JProd_JProduct_UID=JILin_JProduct_ID
  LEFT JOIN juser  on juser.JUser_JUser_UID = JIHdr_CreatedBy_JUser_ID
  LEFT JOIN juser as juser2 on juser2.JUser_JUser_UID = JIHdr_ModifiedBy_JUser_ID
  LEFT JOIN juser as juser3 on juser3.JUser_JUser_UID = JILin_CreatedBy_JUser_ID
  LEFT JOIN juser as juser4 on juser4.JUser_JUser_UID = JILin_ModifiedBy_JUser_ID

WHERE ((JILin_Deleted_b<>true)OR(JILin_Deleted_b IS NULL))
ORDER BY JIHdr_DateInv_DT,JILin_JInvoiceLines_UID