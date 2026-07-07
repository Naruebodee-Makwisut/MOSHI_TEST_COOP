report 50116 "PLSR_Sales Report By Division2"
{
    Caption = 'POS Sales Report By Division';
    DefaultLayout = RDLC;
    RDLCLayout = './04 - LAYOUT/Rep50116_POSSalesReportByDivision.rdl';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(TransSale; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = filter('1..'));

            // ==========================================
            // 1. คอลัมน์ระดับรายการข้อมูลดิบ (Detail Rows)
            // ==========================================
            column(Name_ComInfo; ComInfo.Name) { }
            column(ShowDate; ShowDate) { }
            column(ShowTime; ShowTime) { }
            column(PeriodDate; PeriodDate) { }
            column(ReportFilterText; ReportFilterText) { }

            column(Variant_Code; TempLSCTB."Variant Code") { }
            column(Store_No_TransSale; TempLSCTB."Store No.") { }
            column(Division_Code_TransSale; TempLSCTB."Division Code") { }
            column(Division_TransSale; TempLSCTB."Posting Exception Key") { }
            column(Receipt_No_TransSale; TempLSCTB."Receipt No.") { }
            column(Date_TransSale; Format(TempLSCTB.Date, 0, '<Closing><Day,2>/<Month,2>/<Year4>')) { }
            column(TransType; TempLSCTB."POS Line Description") { }
            column(Item_No_TransSale; TempLSCTB."Item No.") { }
            column(Item_Name_ItemTB; 'TempLSCTB.Epc') { }
            column(Qty; TempLSCTB.Quantity) { }
            column(Unit_of_Measure_TransSale; TempLSCTB."Unit of Measure") { }
            column(BaseQty; TempLSCTB."UOM Quantity") { }
            column(UnitPrice; TempLSCTB.Price) { }
            column(Amount; TempLSCTB.Price * TempLSCTB.Quantity) { }
            column(Discount_Amount_TransSale; TempLSCTB."Discount Amount") { }
            column(TotalAmt; TempLSCTB."Net Amount") { }
            column(ShowVariant; not RettailSetup."PLSPOS_Show Var for Report VIP") { }

            // ==========================================
            // 2. คอลัมน์รวมระดับกลุ่มสินค้า (Item Group Totals)
            // ==========================================
            column(ItemTotal_Qty; ItemTotal_Qty) { }
            column(ItemTotal_BaseQty; ItemTotal_BaseQty) { }
            column(ItemTotal_Amount; ItemTotal_Amount) { }
            column(ItemTotal_Discount; ItemTotal_Discount) { }

            // ==========================================
            // 3. คอลัมน์รวมระดับกลุ่มแผนก (Division Group Totals)
            // ==========================================
            column(DivTotal_Qty; DivTotal_Qty) { }
            column(DivTotal_Amount; DivTotal_Amount) { }
            column(DivTotal_Discount; DivTotal_Discount) { }

            // ==========================================
            // 4. คอลัมน์ยอดรวมสุทธิท้ายรายงาน (Grand Totals)
            // ==========================================
            column(GrandTotal_Qty; GrandTotal_Qty) { }
            column(GrandTotal_Amount; GrandTotal_Amount) { }
            column(GrandTotal_Discount; GrandTotal_Discount) { }

            trigger OnPreDataItem()
            var
                ItemKey: Text;
                DivKey: Text;
                CalcAmount: Decimal;
                Qty: Decimal;
                BaseQty: Decimal;
                UnitPrice: Decimal;
            begin
                TempLSCTB.Reset();
                TempLSCTB.DeleteAll();
                Clear(DictItemQty);
                Clear(DictItemBaseQty);
                Clear(DictItemAmt);
                Clear(DictItemDisc);
                Clear(DictDivQty);
                Clear(DictDivAmt);
                Clear(DictDivDisc);

                Clear(TransType);
                // เคลียร์ค่า Grand Total ท้ายรายงาน
                GrandTotal_Qty := 0;
                GrandTotal_Amount := 0;
                GrandTotal_Discount := 0;

                RettailSetup.Get();

                ReportFilterText := '';

                if Choose1Filter then begin
                    PeriodDate := 'ประจำงวดวันที่ ' + Format(FromDateFilter, 0, '<Closing><Day,2>/<Month,2>/<Year4>') + ' ถึง ' + Format(TodateFilter, 0, '<Closing><Day,2>/<Month,2>/<Year4>');
                    PosSalesQry.SetFilter(DateFilter, '%1..%2', FromDateFilter, TodateFilter);
                end else
                    if Choose2Filter then begin
                        PeriodDate := 'ประจำงวดวันที่ ' + Format(FDateFilter, 0, '<Closing><Day,2>/<Month,2>/<Year4>');
                        PosSalesQry.SetFilter(DateFilter, '%1', FDateFilter);
                    end;

                if StoreFilter <> '' then begin
                    PosSalesQry.SetFilter(StoreNoFilter, StoreFilter);
                    ReportFilterText += 'Store No : ' + FORMAT(StoreFilter + ' ');
                end;

                if ItemNoFilter <> '' then begin
                    PosSalesQry.SetFilter(ItemNoFilter, ItemNoFilter);
                    ReportFilterText += ' Item No: ' + FORMAT(ItemNoFilter + ' ');
                end;

                if DivisionCodeFilter <> '' then begin
                    PosSalesQry.SetFilter(DivisionCodeFilter, DivisionCodeFilter);
                    ReportFilterText += ' Division Code : ' + FORMAT(DivisionCodeFilter + ' ');
                end;
                PosSalesQry.Open();

                while PosSalesQry.Read() do begin

                    ItemKey := PosSalesQry.LSC_Division_Code + '_' + PosSalesQry.Item_No;
                    DivKey := PosSalesQry.LSC_Division_Code;

                    if PosSalesQry.UOM_Quantity <> 0 then
                        Qty := -PosSalesQry.UOM_Quantity
                    else
                        Qty := -PosSalesQry.Quantity;

                    BaseQty := -PosSalesQry.Quantity;

                    if PosSalesQry.UOM_Price <> 0 then
                        UnitPrice := PosSalesQry.UOM_Price
                    else
                        UnitPrice := PosSalesQry.Price;

                    CalcAmount := (UnitPrice * Qty) - PosSalesQry.Discount_Amount;

                    if DictItemQty.ContainsKey(ItemKey) then begin
                        DictItemQty.Set(ItemKey, DictItemQty.Get(ItemKey) + Qty);
                        DictItemBaseQty.Set(ItemKey, DictItemBaseQty.Get(ItemKey) + BaseQty);
                        DictItemAmt.Set(ItemKey, DictItemAmt.Get(ItemKey) + CalcAmount);
                        DictItemDisc.Set(ItemKey, DictItemDisc.Get(ItemKey) + PosSalesQry.Discount_Amount);
                    end else begin
                        DictItemQty.Add(ItemKey, Qty);
                        DictItemBaseQty.Add(ItemKey, BaseQty);
                        DictItemAmt.Add(ItemKey, CalcAmount);
                        DictItemDisc.Add(ItemKey, PosSalesQry.Discount_Amount);
                    end;

                    if DictDivQty.ContainsKey(DivKey) then begin
                        DictDivQty.Set(DivKey, DictDivQty.Get(DivKey) + Qty);
                        DictDivAmt.Set(DivKey, DictDivAmt.Get(DivKey) + CalcAmount);
                        DictDivDisc.Set(DivKey, DictDivDisc.Get(DivKey) + PosSalesQry.Discount_Amount);
                    end else begin
                        DictDivQty.Add(DivKey, Qty);
                        DictDivAmt.Add(DivKey, CalcAmount);
                        DictDivDisc.Add(DivKey, PosSalesQry.Discount_Amount);
                    end;


                    GrandTotal_Qty += Qty;
                    GrandTotal_Amount += CalcAmount;
                    GrandTotal_Discount += PosSalesQry.Discount_Amount;

                    TempLSCTB.Init();
                    TempLSCTB."Store No." := PosSalesQry.Store_No;
                    TempLSCTB."POS Terminal No." := PosSalesQry.POS_Terminal_No;
                    TempLSCTB."Transaction No." := PosSalesQry.Transaction_No;
                    TempLSCTB."Line No." := PosSalesQry.Line_No;
                    TempLSCTB."Variant Code" := PosSalesQry.Variant_Code;
                    TempLSCTB."Receipt No." := PosSalesQry.Receipt_No;
                    TempLSCTB.Date := PosSalesQry.Date;
                    TempLSCTB."Item No." := PosSalesQry.Item_No;
                    // TempLSCTB.Epc := PosSalesQry.Item_Description + ' ' + PosSalesQry.Item_Description_2;
                    TempLSCTB."Division Code" := PosSalesQry.LSC_Division_Code;
                    TempLSCTB."Posting Exception Key" := Format(PosSalesQry.LSC_Division_Code + ' - ' + PosSalesQry.Division_Description);
                    TempLSCTB.Quantity := Qty;
                    TempLSCTB.Price := UnitPrice;
                    TempLSCTB."Discount Amount" := PosSalesQry.Discount_Amount;
                    TempLSCTB."Unit of Measure" := PosSalesQry.Unit_of_Measure;
                    TempLSCTB."UOM Quantity" := BaseQty;

                    TransType := Format(PosSalesQry.Transaction_Type);
                    if PosSalesQry.Return_No_Sale then
                        TransType := 'Refund';
                    TempLSCTB."POS Line Description" := TransType;

                    TempLSCTB."Net Amount" := CalcAmount;

                    TempLSCTB.Insert();
                end;
                PosSalesQry.Close();

                TransSale.SetRange(Number, 1, TempLSCTB.Count());
            end;

            trigger OnAfterGetRecord()
            var
                ItemKey: Text;
                DivKey: Text;
            begin
                if Number = 1 then begin
                    if not TempLSCTB.FindSet() then
                        CurrReport.Break();
                end else
                    if TempLSCTB.Next() = 0 then
                        CurrReport.Break();

                ItemKey := TempLSCTB."Division Code" + '_' + TempLSCTB."Item No.";
                DivKey := TempLSCTB."Division Code";

                // ดึงยอดรวมกลุ่มสินค้า (Item Group) ออกมาใส่คอลัมน์
                if DictItemQty.ContainsKey(ItemKey) then begin
                    ItemTotal_Qty := DictItemQty.Get(ItemKey);
                    ItemTotal_BaseQty := DictItemBaseQty.Get(ItemKey);
                    ItemTotal_Amount := DictItemAmt.Get(ItemKey);
                    ItemTotal_Discount := DictItemDisc.Get(ItemKey);
                end else begin
                    ItemTotal_Qty := 0;
                    ItemTotal_BaseQty := 0;
                    ItemTotal_Amount := 0;
                    ItemTotal_Discount := 0;
                end;

                // ดึงยอดรวมกลุ่มแผนก (Division Group) ออกมาใส่คอลัมน์
                if DictDivQty.ContainsKey(DivKey) then begin
                    DivTotal_Qty := DictDivQty.Get(DivKey);
                    DivTotal_Amount := DictDivAmt.Get(DivKey);
                    DivTotal_Discount := DictDivDisc.Get(DivKey);
                end else begin
                    DivTotal_Qty := 0;
                    DivTotal_Amount := 0;
                    DivTotal_Discount := 0;
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Filter")
                {
                    group("Data Filter")
                    {
                        field("Store No. :"; StoreFilter)
                        {
                            ApplicationArea = All;
                            TableRelation = "LSC Store"."No.";
                            Caption = 'Store No. :';
                            ToolTip = 'Specifies the Store No. to filter the report.';
                        }
                        field("Item No. :"; ItemNoFilter)
                        {
                            ApplicationArea = All;
                            TableRelation = Item."No.";
                            Caption = 'Item No. :';
                            ToolTip = 'Specifies the Item No. to filter the report.';
                        }
                        field("Division Code :"; DivisionCodeFilter)
                        {
                            ApplicationArea = All;
                            TableRelation = "LSC Division".Code;
                            Caption = 'Division Code :';
                            ToolTip = 'Specifies the Division Code to filter the report.';
                        }
                    }
                    group("Date Filter 1")
                    {
                        field(Period; Choose1Filter)
                        {
                            ApplicationArea = All;
                            Caption = 'Period';
                            ToolTip = 'Specifies the Period to filter the report.';
                            trigger OnValidate()
                            begin
                                if Choose1Filter then
                                    Choose2Filter := false
                                else
                                    Choose2Filter := true;
                            end;
                        }
                        group("Period Date")
                        {
                            field("Start Date"; FromDateFilter)
                            {
                                ApplicationArea = All;
                                Editable = Choose1Filter;
                                Caption = 'Start Date';
                                ToolTip = 'Specifies the Start Date to filter the report.';
                            }

                            field("End Date"; TodateFilter)
                            {
                                ApplicationArea = All;
                                Editable = Choose1Filter;
                                Caption = 'End Date';
                                ToolTip = 'Specifies the End Date to filter the report.';
                            }
                        }
                    }
                    group("Date Filter 2")
                    {
                        field("At Date"; Choose2Filter)
                        {
                            ApplicationArea = All;
                            Caption = 'At Date';
                            ToolTip = 'Specifies the At Date to filter the report.';
                            trigger OnValidate()
                            begin
                                if Choose2Filter then
                                    Choose1Filter := false
                                else
                                    Choose1Filter := true;
                            end;
                        }
                        group("At Date filter")
                        {
                            field("Date"; FDateFilter)
                            {
                                ApplicationArea = All;
                                Editable = Choose2Filter;
                                Caption = 'Date';
                                ToolTip = 'Specifies the Date to filter the report.';
                            }
                        }
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            SelectLatestVersion();
            FDateFilter := Today;
            Choose1Filter := false;
            Choose2Filter := true;
        end;

    }

    trigger OnPreReport()
    begin
        ComInfo.Get();
        ShowDate := FORMAT(Today, 0, '<Closing><Day,2>/<Month,2>/<Year4>');
        ShowTime := LSVIPRepFunction.AVTimeFormat(Time);
    end;

    var
        ComInfo: Record "Company Information";
        // ItemTB: Record Item; ไปอยู่ในคิวรี่แทนแล้ว
        //  DivisonTB: Record "LSC Division";
        // TransHeaderTB: Record "LSC Transaction Header";
        RettailSetup: Record "LSC Retail Setup";
        TempLSCTB: Record "LSC Trans. Sales Entry" temporary;
        LSVIPRepFunction: Codeunit "PLSR_Report Function";
        PosSalesQry: Query "PLSR_Sales Report By DivisionQ"; //ตัวแปรรับคิวรี่มาใช้งาน ไม่ต้องดึง table เยอะ
        ShowTime: Text[50];
        ShowDate: Text[50];
        PeriodDate: Text[150];
        ReportFilterText: Text[250];
        TransType: Text[50];
        StoreFilter: Code[20];
        ItemNoFilter: Code[20];
        DivisionCodeFilter: Text[50];
        FromDateFilter: Date;
        TodateFilter: Date;
        FDateFilter: Date;
        Choose1Filter: Boolean;
        Choose2Filter: Boolean;

        DictItemQty: Dictionary of [Text, Decimal];
        DictItemBaseQty: Dictionary of [Text, Decimal];
        DictItemAmt: Dictionary of [Text, Decimal];
        DictItemDisc: Dictionary of [Text, Decimal];
        DictDivQty: Dictionary of [Text, Decimal];
        DictDivAmt: Dictionary of [Text, Decimal];
        DictDivDisc: Dictionary of [Text, Decimal];

        ItemTotal_Qty: Decimal;
        ItemTotal_BaseQty: Decimal;
        ItemTotal_Amount: Decimal;
        ItemTotal_Discount: Decimal;
        DivTotal_Qty: Decimal;
        DivTotal_Amount: Decimal;
        DivTotal_Discount: Decimal;
        GrandTotal_Qty: Decimal;
        GrandTotal_Amount: Decimal;
        GrandTotal_Discount: Decimal;
}