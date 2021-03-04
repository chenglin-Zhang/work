<?xml version="1.0"?>
<!-- *************************************************************************

Stylesheet for POSLog transformations in TxCollector
(included in root stylesheet POSLog.xsl)

written by: Josef Rüschoff (extern)

The sources are TP.net POS transactions in .xml format. 

The generated POSLog transactions are based on POSLog V2.2.1.

The stylesheet can be used for TPDotnet Versions 3.3 and 3.5

******************************************************************************
Version history:

1.1     25.09.2007:  initial version (K&OE, Austria)

1.4     07.03.2008:  bug fixing: transactions generated in debug mode where not correctly transformed

1.5     09.01.2009:  extensions for Loyalty (CUSTOMER / LOYALTY)

1.6     15.01.2009:  <WN:DateTime> attribute inserted for <Total> items 
        15.01.2009:  <WN:Coupon> node inserted under <RetailTransaction>
        03.02.2009:  <WN:OperatorBypassApproval> inserted under <RetailTransaction> for VOID_RECEIPT or ABORT_RECEIPT
        03.02.2009:  completed and corrected: STORE / RECALL handling
        19.03.2009:  <BeginDateTime> inserted in <TransactionLink> elements

1.7     06.08.2009:  @Code attribute in <Country> element (<Customer>/<Address>) eliminated

    Label 3.5.3

1.8     04.06.2009:  <WN:LockWorkstation> inserted as <LineItem> element
        16.07.2009:  <SegmentID> eliminated from <WN:CustomerSegment>
        09.10.2009:  new STAT_ART_RETURN_VOID transformed to <Return>
        09.10.2009:  new STAT_SELL_MEDIA_VOID transferred to <GiftCertificate>
        
    Label 3.5.4.2 (3.5.5.5, 3.7.1.7)

1.9     21.06.2010:  change calculation of transaction tax amount

    Label 3.9.0.0 (3.9.5.0)
    
1.10    27.10.2010:  internal optimization: TaType now transferred as parameter
        10.12.2010:  arts namespace inserted as default namespace
        10.12.2010:  calculation of transaction tax amount corrected

1.11    05.01.2011:  arts default namespace removed

    Label 4.0.2.0

1.12    22.02.2013:  <WN:OpenDrawer> inserted for VOID_RECEIPT

1.13	  05.04.2013: default namespace definition inserted (MKS #1066249)

    Label 5.0.0.0

1.14    11.10.2013:  elements with default values 0 and '' in the source transactions are now always correctly considered (#1209217)

    Label 5.0.1.6

1.15    24.03.2014:  the <Total> types 'TransactionNetAmount' and 'TransactionGrandAmount' are always generated (#1367222)

1.16   21.05.2014: Added Handling for CUSTOMER_ORDER

1.17 22.05.2014: Used Pretty Print of XMLSSpy to ease MKS Diff

1.19 22.05.2014: Added hangling for STORE_RECEIPT_GDA & RECALL_RECEIPT_GDA

1.19 22.05.2014: Added handlig for FIXED_DISC_INFO Object

1.20 22.05.2014: Added handling for ORDERED_ARTICLE & ORDERED_ARTICLE_VOID

1.21 19.06.2015: Added handling for ART_RESTRICTION_INFO

	Label 6.0.0.0

1.22 13.10.2015: Added Alpha2Code to templates for simplified customizing (#1784807)

1.23 29.01.2019: Added Tender of Rounding error(tenderid:060), ALDI project
1.24 16.05.2019: Change Tender of Rounding error(tenderid:60), ALDI project
*************************************************************************  -->
<xsl:stylesheet version="1.0" xmlns="http://www.nrf-arts.org/IXRetail/namespace/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:WN="http://www.wincor-nixdorf.com" exclude-result-prefixes="xsl xsi">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:include href="POSLog_LineItems.xsl"/>
	<xsl:template name="RetailTransaction">
		<xsl:param name="TaType"/>
		<xsl:param name="Alpha2Code"/>
		<RetailTransaction Version="2.2">
			<!-- attributes -->
			<xsl:choose>
				<xsl:when test="$TaType = 'ST'">
					<xsl:attribute name="TransactionStatus">Suspended</xsl:attribute>
				</xsl:when>
				<xsl:when test="$TaType = 'VR' or $TaType = 'DV' or $TaType = 'AV'">
					<xsl:attribute name="TransactionStatus">PostVoided</xsl:attribute>
				</xsl:when>
				<xsl:when test="$TaType = 'DE' or $TaType = 'AS'">
					<xsl:attribute name="TransactionStatus">InProcess</xsl:attribute>
					<xsl:choose>
						<xsl:when test="$TaType = 'AS'">
							<xsl:attribute name="TypeCode">WN:Assortment</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="TypeCode">WN:Deposit</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="CORRECT_RECEIPT">
						<xsl:attribute name="TransactionStatus">Replaced</xsl:attribute>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			
			
			<xsl:variable name="VoidFlag">
				<xsl:choose>
					<xsl:when test="$TaType = 'VR' or $TaType = 'DV' or $TaType = 'AV'">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!-- 
      <xsl:choose>

        <xsl:when test="$TaType = 'AB'">
        </xsl:when>

        <xsl:when test="$TaType = 'ST' and STORE_RECEIPT/szInfo != 'ISCAN'">
          - no line items are processed in this template!! -
          <xsl:for-each select="STORE_RECEIPT">
            <xsl:if test="position() = 2">
              <TransactionLink ReasonCode="Resume">
                <RetailStoreID>
                  <xsl:value-of select="lRetailStoreID"/>
                </RetailStoreID>
                <WorkstationID>
                  <xsl:value-of select="lWorkstationNmbrStored"/>
                </WorkstationID>
                <SequenceNumber>
                  <xsl:value-of select="lTaNmbrStored"/>
                </SequenceNumber>
              </TransactionLink>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>

        <xsl:otherwise>
      -->
			<!-- the following items are sequentially transformed to LineItems -->
			<!-- 更改：aldi客制化，不传单行取消。(feng shanzhi, 2019-03-08) -->
                              <!-- STAT_ART_LINE_VOID | -->
			<!-- 更改：aldi客制化，不传退货单行取消。(feng shanzhi, 2019-05-28) -->
                              <!-- STAT_ART_RETURN_VOID | -->
			<xsl:for-each select="ART_SALE | 
                              ART_RETURN |
                              ART_LINE_VOID |
                              ART_IMMEDIATE_VOID |
                              STAT_ART_IMMEDIATE_VOID |
                              ORDERED_ARTICLE |
                              ORDERED_ARTICLE_VOID |
                              FIX_DISC_INFO |
                              DISC_INFO |
                              VAT |
                              TAX_INCLUDED |
                              TAX_EXCLUDED |
                              ISCAN_SALE |
                              LOCK |
                              MEDIA |
                              STAT_MEDIA_LINE_VOID |
                              STAT_MEDIA_IMMEDIATE_VOID |
                              SELL_MEDIA |
                              STAT_SELL_MEDIA_VOID |
                              DEPOSIT_IN |
                              DEPOSIT_OUT |
                              DEPOSIT_VOID |
                              LOYALTY_ACCOUNT |
                              PAYONCUSTOMERACCOUNT |
                              NOSALE">
				<xsl:call-template name="LineItems">
					<xsl:with-param name="VoidFlag" select="$VoidFlag"/>
					<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
				</xsl:call-template>
			</xsl:for-each>
			
			
					
			<xsl:variable name="TaxTotal">
				<xsl:value-of select="sum(TAX_INCLUDED/dIncludedTaxValue) + sum(TAX_EXCLUDED/dExcludedTaxValue)"/>
			</xsl:variable>
			<xsl:for-each select="TOTAL">
				<!-- Added Tender 60 to POSLOG -->
				<!-- <xsl:if test="/TAS/NEW_TA/TOTAL/dRoundingError">
					<LineItem>
						<SequenceNumber>
							<xsl:value-of select="Hdr/lTaSeqNmbr"/>
						</SequenceNumber>
						<xsl:if test="szDate != ''">
							<BeginDateTime>
								<xsl:call-template name="formatdatetime">
									<xsl:with-param name="datetime" select="szDate"/>
								</xsl:call-template>
							</BeginDateTime>
						</xsl:if>
						<Tender>
							<xsl:variable name="Amount">
								<xsl:value-of select="/TAS/NEW_TA/TOTAL/dRoundingError"/>
							</xsl:variable>
							<xsl:attribute name="TenderType">Cash</xsl:attribute>
							<xsl:attribute name="TypeCode">
								<xsl:choose>
									<xsl:when test="$Amount &gt; 0">Refund</xsl:when>
									<xsl:otherwise>Sale</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							
							<xsl:attribute name="WN:ExternalTenderType">60</xsl:attribute>
							<xsl:if test="PAYMENT/szPosLogExternalID != ''">
								<xsl:attribute name="WN:EFTTenderType"><xsl:value-of select="PAYMENT/szPosLogExternalID"/></xsl:attribute>
							</xsl:if>
							<xsl:attribute name="WN:Media"><xsl:value-of select="/TAS/NEW_TA/MEDIA/PAYMENT/lMediaNmbr"/></xsl:attribute>
							<xsl:attribute name="WN:MediaMember"><xsl:value-of select="/TAS/NEW_TA/MEDIA/PAYMENT/lMediaMember"/></xsl:attribute>
							<Amount>
								<xsl:call-template name="AbsNumber">
									<xsl:with-param name="number" select="$Amount"/>
								</xsl:call-template>
							</Amount>
							<WN:Quantity>1</WN:Quantity>
						</Tender>
						<xsl:call-template name="CreateInfo">
							<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
						</xsl:call-template>
					</LineItem>
				</xsl:if> -->
				
				
				<!--****************************  CRM ****************************-->
				<xsl:call-template name="CRM_INFO">
					<xsl:with-param name="SKU" select="szItemLookupCode"/>
				</xsl:call-template>
				
				
				<xsl:if test="/TAS/NEW_TA/ALDI_CalculateTax/TotalAmount != ''">						
				<TotalAmount>
					<xsl:value-of select="/TAS/NEW_TA/ALDI_CalculateTax/TotalAmount"/>
				</TotalAmount>
				</xsl:if>
				<xsl:if test="/TAS/NEW_TA/ALDI_CalculateTax/TotalTaxAmount != ''">
					<TotalTaxAmount>
						<xsl:value-of select="/TAS/NEW_TA/ALDI_CalculateTax/TotalTaxAmount"/>
					</TotalTaxAmount>
				</xsl:if>
				<xsl:if test="/TAS/NEW_TA/ALDI_CalculateTax/TotalAmountWithoutTax != ''">
					<TotalAmountWithoutTax>
						<xsl:value-of select="/TAS/NEW_TA/ALDI_CalculateTax/TotalAmountWithoutTax"/>
					</TotalAmountWithoutTax>
				</xsl:if>
				
				<!--订单总折后价合计税额 -->
				<xsl:variable name="ActualTotalTaxAmount">
					<xsl:choose>
						<xsl:when test="/TAS/NEW_TA/ALDI_CalculateTax/ActualTotalTaxAmount = 0" >
							<xsl:value-of select="0"/>
						</xsl:when>
						<xsl:when test="/TAS/NEW_TA/ALDI_CalculateTax/ActualTotalTaxAmount != 0" >
							<xsl:value-of select="format-number(/TAS/NEW_TA/ALDI_CalculateTax/ActualTotalTaxAmount, '#0.##')"/>
						</xsl:when>
						<xsl:otherwise>
						  <xsl:value-of select="$TaxTotal"/>
						</xsl:otherwise>
					</xsl:choose>				
				</xsl:variable>
				
				<!--订单总折后价合计不含税金额 -->
				<xsl:variable name="ActualTotalAmountWithoutTax">
					<xsl:choose>
						<xsl:when test="dTotalSale">
							<xsl:value-of select="format-number(dTotalSale - $ActualTotalTaxAmount, '#0.##')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>0</xsl:text>
						</xsl:otherwise>
					</xsl:choose>			
				</xsl:variable>
								
				<!-- Added Tender 60 to POSLOG -->
				<Total TotalType="TransactionNetAmount">
					<xsl:if test="szDate">
						<xsl:attribute name="WN:DateTime"><xsl:call-template name="formatdatetime"><xsl:with-param name="datetime" select="szDate"/></xsl:call-template></xsl:attribute>
					</xsl:if>
					<!-- 
					<xsl:choose>						
						<xsl:when test="dTotalNet">
							<xsl:call-template name="InvertNumber">
								<xsl:with-param name="number" select="dTotalNet"/>
								<xsl:with-param name="InvertFlag" select="$VoidFlag"/>
							</xsl:call-template>
						</xsl:when>												
						<xsl:otherwise>
							<xsl:text>0</xsl:text>
						</xsl:otherwise>										
					</xsl:choose>
					-->
					<xsl:value-of select="$ActualTotalAmountWithoutTax"/>
				</Total>
				<xsl:if test="(not(lSortTotal) or lSortTotal = 0)">
					<Total TotalType="TransactionTaxAmount">
						<xsl:if test="szDate">
							<xsl:attribute name="WN:DateTime"><xsl:call-template name="formatdatetime"><xsl:with-param name="datetime" select="szDate"/></xsl:call-template></xsl:attribute>
						</xsl:if>
						<xsl:call-template name="InvertNumber">
							<xsl:with-param name="number" select="$ActualTotalTaxAmount"/>
							<xsl:with-param name="InvertFlag" select="$VoidFlag"/>
						</xsl:call-template>
					</Total>
				</xsl:if>
				
				<Total TotalType="TransactionGrandAmount">
					<xsl:if test="szDate">
						<xsl:attribute name="WN:DateTime"><xsl:call-template name="formatdatetime"><xsl:with-param name="datetime" select="szDate"/></xsl:call-template></xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="dTotalSale">
							<xsl:call-template name="InvertNumber">
								<xsl:with-param name="number" select="dTotalSale"/>
								<xsl:with-param name="InvertFlag" select="$VoidFlag"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>0</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</Total>
							
			</xsl:for-each>
												
			
			
			<!-- Handling of ART_RESTRICTION_INFO -->
			<xsl:for-each select="ART_RESTRICTION_INFO">
				<xsl:variable name="QuestionID">
					<xsl:choose>
						<xsl:when test="szRestrictionType='CUSTOMER_AGE_CONTROL'">CustomerAgeControl</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="szRestrictionType"/>
						</xsl:otherwise>	
					</xsl:choose>					
				</xsl:variable>		
				<xsl:variable name="QuestionText">
					<xsl:if test="szRestrictionType='CUSTOMER_AGE_CONTROL'">MinAge=<xsl:value-of select="lMinAge"/></xsl:if>
				</xsl:variable>
				<xsl:variable name="QuestionAnswer">
					<xsl:choose>
						<xsl:when test="./bResult">
							<xsl:choose>
								<xsl:when test="bResult=0">false</xsl:when>
								<xsl:otherwise>true</xsl:otherwise>
							</xsl:choose>
						</xsl:when>					
						<xsl:otherwise>false</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:call-template name="RestrictionValidation">
					<xsl:with-param name="QuestionID">
							<xsl:value-of select="$QuestionID"/>						
					</xsl:with-param>
					<xsl:with-param name="QuestionText">
						<xsl:value-of select="$QuestionText"/>
					</xsl:with-param>
					<xsl:with-param name="QuestionAnswer">
						<xsl:value-of select="$QuestionAnswer"/>
					</xsl:with-param>
					<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:for-each select="CUSTOMER_ORDER">
				<xsl:call-template name="CustomerOrder">
					<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
				</xsl:call-template>	     
			</xsl:for-each>
			<xsl:for-each select="CUSTOMER/KEY_CUSTOMER">
				<xsl:call-template name="customer">
					<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:if test="$TaType = 'CM'">
				<xsl:for-each select="PAYONCUSTOMERACCOUNT/KEY_CUSTOMER">
					<xsl:call-template name="customer">
						<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
			<xsl:for-each select="EMPL_AS_CUST">
				<Customer>
					<Worker>
						<WorkerID>
							<xsl:value-of select="EMPLOYEE/lEmployeeID"/>
						</WorkerID>
						<Name>
							<FullName>
								<xsl:value-of select="EMPLOYEE/szEmplName"/>
							</FullName>
						</Name>
					</Worker>
				</Customer>
			</xsl:for-each>
			<!--Ticket Void -->
			<xsl:for-each select="VOID_RECEIPT">
				<TransactionLink ReasonCode="Voided">
					<RetailStoreID>
						<xsl:value-of select="../HEADER/lRetailStoreID"/>
					</RetailStoreID>
					<WorkstationID>
						<xsl:value-of select="lVoidedWorkstationNmbr"/>
					</WorkstationID>
					<SequenceNumber>
						<xsl:value-of select="lVoidedTaNmbr"/>
					</SequenceNumber>
				</TransactionLink>
				<xsl:variable name="TaCreateNmbr">
					<xsl:value-of select="Hdr/lTaCreateNmbr"/>
				</xsl:variable>
				<xsl:for-each select="following-sibling::OVERRIDE[Hdr/lTaRefToCreateNmbr = $TaCreateNmbr]">
					<WN:OperatorBypassApproval>
						<SequenceNumber>
							<xsl:value-of select="Hdr/lTaSeqNmbr"/>
						</SequenceNumber>
						<ApproverID>
							<xsl:attribute name="OperatorName"><xsl:value-of select="szEmplName"/></xsl:attribute>
							<xsl:value-of select="lEmployeeID"/>
						</ApproverID>
						<Description>
							<xsl:value-of select="szReason"/>
						</Description>
					</WN:OperatorBypassApproval>
				</xsl:for-each>
				<xsl:call-template name="OpenDrawer">
					<xsl:with-param name="TaCreateNmbr" select="$TaCreateNmbr"/>
					<xsl:with-param name="Alpha2Code" select="$Alpha2Code"/>
				</xsl:call-template>
			</xsl:for-each>
			<!-- Correct Receipt -->
			<xsl:for-each select="CORRECT_RECEIPT">
				<TransactionLink ReasonCode="WN:Corrected">
					<RetailStoreID>
						<xsl:value-of select="../HEADER/lRetailStoreID"/>
					</RetailStoreID>
					<WorkstationID>
						<xsl:value-of select="lVoidedWorkstationNmbr"/>
					</WorkstationID>
					<SequenceNumber>
						<xsl:value-of select="lVoidedTaNmbr"/>
					</SequenceNumber>
					<BeginDateTime>
						<xsl:call-template name="formatdatetime">
							<xsl:with-param name="datetime" select="szDate"/>
						</xsl:call-template>
					</BeginDateTime>
				</TransactionLink>
			</xsl:for-each>
			<!-- DEPOSIT_OUT -->
			<xsl:for-each select="DEPOSIT_OUT">
				<TransactionLink ReasonCode="Resume">
					<RetailStoreID>
						<xsl:value-of select="../HEADER/lRetailStoreID"/>
					</RetailStoreID>
					<WorkstationID>
						<xsl:value-of select="lWorkstationNmbrRef"/>
					</WorkstationID>
					<SequenceNumber>
						<xsl:value-of select="lTaNmbrRef"/>
					</SequenceNumber>
					<BeginDateTime>
						<xsl:call-template name="formatdatetime">
							<xsl:with-param name="datetime" select="szDateRef"/>
						</xsl:call-template>
					</BeginDateTime>
				</TransactionLink>
			</xsl:for-each>
			<!-- DEPOSIT_VOID -->
			<xsl:for-each select="DEPOSIT_VOID">
				<TransactionLink ReasonCode="Voided">
					<RetailStoreID>
						<xsl:value-of select="../HEADER/lRetailStoreID"/>
					</RetailStoreID>
					<WorkstationID>
						<xsl:value-of select="lWorkstationNmbrRef"/>
					</WorkstationID>
					<SequenceNumber>
						<xsl:value-of select="lTaNmbrRef"/>
					</SequenceNumber>
					<BeginDateTime>
						<xsl:call-template name="formatdatetime">
							<xsl:with-param name="datetime" select="szDateRef"/>
						</xsl:call-template>
					</BeginDateTime>
				</TransactionLink>
			</xsl:for-each>
			<!-- multiple STORE_RECEIPT And STORE_RECEIPT_GDA  -->
			<xsl:if test="$TaType = 'ST' and (STORE_RECEIPT | STORE_RECEIPT_GDA)/szInfo != 'ISCAN'">				
				<xsl:for-each select="( STORE_RECEIPT | STORE_RECEIPT_GDA )[position()=2]">
					<TransactionLink ReasonCode="Resume">
						<RetailStoreID>
							<xsl:value-of select="lRetailStoreID"/>
						</RetailStoreID>
						<WorkstationID>
							<xsl:value-of select="lWorkstationNmbrStored"/>
						</WorkstationID>
						<SequenceNumber>
							<xsl:value-of select="lTaNmbrStored"/>
						</SequenceNumber>
						<BeginDateTime>
							<xsl:call-template name="formatdatetime">
								<xsl:with-param name="datetime" select="szDateRef"/>
							</xsl:call-template>
						</BeginDateTime>
					</TransactionLink>
				</xsl:for-each>
			</xsl:if>
			<!-- RECALL_RECEIPT & RECALL_RECEIPT_GDA  -->
			<xsl:if test="$TaType != 'ST' and $VoidFlag = 'false' and ( RECALL_RECEIPT | RECALL_RECEIPT_GDA )">				
				<xsl:for-each select=" ( STORE_RECEIPT | STORE_RECEIPT_GDA )[position()=1]">
					<TransactionLink ReasonCode="Resume">
						<RetailStoreID>
							<xsl:value-of select="../HEADER/lRetailStoreID"/>
						</RetailStoreID>
						<WorkstationID>
							<xsl:value-of select="lWorkstationNmbrStored"/>
						</WorkstationID>
						<SequenceNumber>
							<xsl:value-of select="lTaNmbrStored"/>
						</SequenceNumber>
						<BeginDateTime>
							<xsl:call-template name="formatdatetime">
								<xsl:with-param name="datetime" select="szDateRef"/>
							</xsl:call-template>
						</BeginDateTime>
					</TransactionLink>
				</xsl:for-each>
			</xsl:if>			
			<!--Ticket Abort -->
			<xsl:for-each select="ABORT_RECEIPT">
				<xsl:variable name="TaCreateNmbr">
					<xsl:value-of select="Hdr/lTaCreateNmbr"/>
				</xsl:variable>
				<xsl:for-each select="following-sibling::OVERRIDE[Hdr/lTaRefToCreateNmbr = $TaCreateNmbr]">
					<WN:OperatorBypassApproval>
						<SequenceNumber>
							<xsl:value-of select="Hdr/lTaSeqNmbr"/>
						</SequenceNumber>
						<ApproverID>
							<xsl:attribute name="OperatorName"><xsl:value-of select="szEmplName"/></xsl:attribute>
							<xsl:value-of select="lEmployeeID"/>
						</ApproverID>
						<Description>
							<xsl:value-of select="szReason"/>
						</Description>
					</WN:OperatorBypassApproval>
				</xsl:for-each>
			</xsl:for-each>
			<!-- COUPON -->  
			<!-- <xsl:for-each select="COUPON"> -->
			<!--默认取第一个COUPON节点的优惠券信息  2020/02/19 by zengling -->
			<xsl:for-each select="(COUPON)[position()=1]">
				<WN:Coupon>
					<xsl:if test="szDescription != ''">
						<Description>
							<xsl:value-of select="szDescription"/>
						</Description>
					</xsl:if>
					<PrimaryLabel>
						<xsl:value-of select="szCouponID"/>
					</PrimaryLabel>
					<xsl:if test="szScanCode != ''">
						<ScanCode>
							<xsl:value-of select="szScanCode"/>
						</ScanCode>
					</xsl:if>
				</WN:Coupon>
			</xsl:for-each>
			
							
			<!-- 
        </xsl:otherwise>
      </xsl:choose>
      -->
		</RetailTransaction>
	</xsl:template>
	<!--*********************************************************************************************************-->
	<!--****************************               template: CustomerOrder          ****************************-->
	<xsl:template name="CustomerOrder">
		<xsl:param name="Alpha2Code"/>
		<Pickup>
			<CustomerID>
				<xsl:value-of select="KEY_CUSTOMER/szCustomerID"/>
			</CustomerID>
			<CustomerName>
				<xsl:if test="KEY_CUSTOMER/szSalutation != ''">
					<Salutation>
						<xsl:value-of select="KEY_CUSTOMER/szSalutation"/>
					</Salutation>
				</xsl:if>
				<Name TypeCode="GivenName">
					<xsl:value-of select="KEY_CUSTOMER/szFirstName"/>
				</Name>
				<Name TypeCode="FamilyName">
					<xsl:value-of select="KEY_CUSTOMER/szLastName"/>
				</Name>
				<FullName>
					<xsl:if test="KEY_CUSTOMER/szSalutation != ''">
						<xsl:value-of select="KEY_CUSTOMER/szSalutation"/>
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="KEY_CUSTOMER/szFirstName"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="KEY_CUSTOMER/szLastName"/>
				</FullName>
				<xsl:if test="KEY_CUSTOMER/szFirstBusinessName != ''">
					<OfficialName>
						<xsl:value-of select="KEY_CUSTOMER/szFirstBusinessName"/>
					</OfficialName>
				</xsl:if>
			</CustomerName>
			<Address>
				<AddressLine>
					<xsl:value-of select="KEY_CUSTOMER/szStreetName"/>
				</AddressLine>
				<City>
					<xsl:value-of select="KEY_CUSTOMER/szCityName"/>
				</City>
				<PostalCode>
					<xsl:value-of select="KEY_CUSTOMER/szPostalLocationZipCode"/>
				</PostalCode>
				<xsl:if test="KEY_CUSTOMER/szPostalLocationCountryCode != ''">
					<Country>
						<xsl:value-of select="KEY_CUSTOMER/szPostalLocationCountryCode"/>
					</Country>
				</xsl:if>
			</Address>
			<xsl:if test="KEY_CUSTOMER/szPhoneNmbr != ''">
				<TelephoneNumber>
					<xsl:value-of select="KEY_CUSTOMER/szPhoneNmbr"/>
				</TelephoneNumber>
			</xsl:if>
			<xsl:if test="KEY_CUSTOMER/szBirthDate != ''">
				<Birthdate>
					<xsl:call-template name="formatdate">
						<xsl:with-param name="datetime" select="KEY_CUSTOMER/szBirthDate"/>
					</xsl:call-template>
				</Birthdate>
			</xsl:if>
			<xsl:if test="KEY_CUSTOMER/szLanguageCode != ''">
				<Locale>
					<xsl:value-of select="KEY_CUSTOMER/szLanguageCode"/>
				</Locale>
			</xsl:if>
			<xsl:if test="KEY_CUSTOMER/szTaxNmbr != ''">
				<TaxCertificate>
					<xsl:value-of select="KEY_CUSTOMER/szTaxNmbr"/>
				</TaxCertificate>
			</xsl:if>
			<xsl:if test="szDateTime != ''">
				<ActualDateTime>
					<xsl:value-of select="szDateTime"/>
				</ActualDateTime>
			</xsl:if>
			<Method>
				<xsl:value-of select="szDeliveryMethod"/>
			</Method>
			<Notes>
				<xsl:value-of select="szDocumentNumber"/>
			</Notes>
		</Pickup>
	</xsl:template>
		<!--*********************************************************************************************************-->
	<!--****************************               template: RestrictionValidation          ****************************-->
	<xsl:template name="RestrictionValidation">
		<xsl:param name="QuestionID"/>
		<xsl:param name="QuestionText"/>
		<xsl:param name="QuestionAnswer"/>
		<xsl:param name="Alpha2Code"/>
		<RestrictionValidation>
			<xsl:attribute name="QuestionID">
				<xsl:value-of select="$QuestionID"/>
			</xsl:attribute>
			<xsl:if test="$QuestionText != ''">
				<QuestionText>
					<xsl:value-of select="$QuestionText"/>
				</QuestionText>
			</xsl:if>
			<QuestionAnswer>
				<xsl:value-of select="$QuestionAnswer"/>
			</QuestionAnswer>
		</RestrictionValidation>
	</xsl:template>
	<!--*********************************************************************************************************-->
	<!--****************************               template: Customer                  ****************************-->
	<xsl:template name="customer">
		<xsl:param name="Alpha2Code"/>
		<Customer>
			<xsl:if test="szStatusCode != ''">
				<xsl:attribute name="WN:StatusCode"><xsl:value-of select="szStatusCode"/></xsl:attribute>
			</xsl:if>
			<CustomerID>
				<xsl:value-of select="szCustomerID"/>
			</CustomerID>
			<CustomerName>
				<xsl:if test="szSalutation != ''">
					<Salutation>
						<xsl:value-of select="szSalutation"/>
					</Salutation>
				</xsl:if>
				<Name TypeCode="GivenName">
					<xsl:value-of select="szFirstName"/>
				</Name>
				<Name TypeCode="FamilyName">
					<xsl:value-of select="szLastName"/>
				</Name>
				<FullName>
					<xsl:if test="szSalutation != ''">
						<xsl:value-of select="szSalutation"/>
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="szFirstName"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="szLastName"/>
				</FullName>
				<xsl:if test="szFirstBusinessName != ''">
					<OfficialName>
						<xsl:value-of select="szFirstBusinessName"/>
					</OfficialName>
				</xsl:if>
			</CustomerName>
			<Address>
				<AddressLine>
					<xsl:value-of select="szStreetName"/>
				</AddressLine>
				<City>
					<xsl:value-of select="szCityName"/>
				</City>
				<PostalCode>
					<xsl:value-of select="szPostalLocationZipCode"/>
				</PostalCode>
				<xsl:if test="szPostalLocationCountryCode != ''">
					<Country>
						<xsl:value-of select="szPostalLocationCountryCode"/>
					</Country>
				</xsl:if>
			</Address>
			<xsl:if test="szPhoneNmbr != ''">
				<TelephoneNumber>
					<xsl:value-of select="szPhoneNmbr"/>
				</TelephoneNumber>
			</xsl:if>
			<xsl:if test="szBirthDate != ''">
				<Birthdate>
					<xsl:call-template name="formatdate">
						<xsl:with-param name="datetime" select="szBirthDate"/>
					</xsl:call-template>
				</Birthdate>
			</xsl:if>
			<xsl:if test="szLanguageCode != ''">
				<Locale>
					<xsl:value-of select="szLanguageCode"/>
				</Locale>
			</xsl:if>
			<xsl:if test="szTaxNmbr != ''">
				<TaxCertificate>
					<xsl:value-of select="szTaxNmbr"/>
				</TaxCertificate>
			</xsl:if>
			<xsl:for-each select="../../LOYALTY">
				<WN:LoyaltyCardID>
					<xsl:value-of select="szCardID"/>
				</WN:LoyaltyCardID>
				<xsl:for-each select="SEGMENT">
					<xsl:for-each select="*">
						<xsl:if test="substring(name(.),1,4) = 'szID'">
							<WN:CustomerSegment>
								<xsl:value-of select="."/>
							</WN:CustomerSegment>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</Customer>
	</xsl:template>
	
	<!--*********************************************************************************************************-->
	<!--****************************              template: CRM              ****************************-->
	<xsl:template name="CRM_INFO">
		<xsl:param name="SKU"/>
		<xsl:if test="/TAS/NEW_TA/CRM_INFO/szCustomerId != ''">
			<WN:CUSTOMER>
				<WN:CustomerId><xsl:value-of select="/TAS/NEW_TA/CRM_INFO/szCustomerId"/></WN:CustomerId>
				<WN:Name><xsl:value-of select="/TAS/NEW_TA/CRM_INFO/szName"/></WN:Name>
				<WN:MobilePhone><xsl:value-of select="/TAS/NEW_TA/CRM_INFO/szMobilePhone"/></WN:MobilePhone>
				<WN:dRefundCoupon><xsl:value-of select="/TAS/NEW_TA/CRM_INFO/dRefundCoupon"/></WN:dRefundCoupon>
			</WN:CUSTOMER>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
