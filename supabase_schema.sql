-- Software Schema Definition: Vishnu Balaji Global Trade CRM
-- Anchored baseline mapping to Supabase Postgres Engine with multi-tenant isolation

-- 1. Core Leads & Buyer Inquiries Table
CREATE TABLE IF NOT EXISTS public.inquiries (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    tenant_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
    name TEXT NOT NULL,
    company TEXT DEFAULT 'Independent Buyer',
    email TEXT NOT NULL,
    country TEXT,
    product TEXT NOT NULL,
    quantity TEXT DEFAULT '1',
    unit TEXT,
    destination_port TEXT DEFAULT 'FOB Origin India',
    message TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    pipeline_stage TEXT DEFAULT 'new',
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Mandi Price Index rates (Global Reference Data)
CREATE TABLE IF NOT EXISTS public.mandi_rates (
    product TEXT PRIMARY KEY,
    location TEXT NOT NULL,
    domestic_rate TEXT NOT NULL,
    export_rate TEXT NOT NULL,
    export_dest TEXT NOT NULL,
    trend TEXT,
    status TEXT CHECK (status IN ('up', 'down')),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Shipment Tracking & Telemetry
CREATE TABLE IF NOT EXISTS public.shipments (
    id TEXT PRIMARY KEY,
    tenant_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
    buyer TEXT NOT NULL,
    product TEXT NOT NULL,
    container TEXT,
    qty NUMERIC,
    unit TEXT,
    discharge_port TEXT,
    carrier TEXT,
    status TEXT,
    step INT DEFAULT 1,
    eta DATE,
    delay_risk TEXT,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Document Compliance SCREENING
CREATE TABLE IF NOT EXISTS public.compliance_checks (
    id TEXT PRIMARY KEY,
    tenant_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
    company TEXT NOT NULL,
    country TEXT NOT NULL,
    item TEXT NOT NULL,
    type TEXT NOT NULL,
    status TEXT DEFAULT 'Hold',
    description TEXT,
    level TEXT CHECK (level IN ('error', 'warning', 'success')),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Forex Exposure & Forward Cover Recommendation
CREATE TABLE IF NOT EXISTS public.forex_exposure (
    currency TEXT PRIMARY KEY,
    tenant_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
    amount NUMERIC NOT NULL,
    inr_equivalent NUMERIC NOT NULL,
    rate NUMERIC NOT NULL,
    exposure_type TEXT,
    hedging_status TEXT,
    recommendation TEXT,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Letter of Credit Discrepancy Watchlist
CREATE TABLE IF NOT EXISTS public.lc_discrepancies (
    lc_number TEXT PRIMARY KEY,
    tenant_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
    buyer TEXT NOT NULL,
    product TEXT NOT NULL,
    shipment_deadline DATE,
    status TEXT,
    discrepancies JSONB DEFAULT '[]'::jsonb,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 7. Export Incentives Claim Tracker
CREATE TABLE IF NOT EXISTS public.incentive_claims (
    id TEXT PRIMARY KEY,
    tenant_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
    buyer TEXT NOT NULL,
    product TEXT NOT NULL,
    fob_val TEXT,
    scheme TEXT,
    estimated_claim TEXT,
    status TEXT,
    ref TEXT,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 8. Immutable Audit Logs Table (GDPR/ISO Governance)
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
    timestamp TIMESTAMPTZ DEFAULT now(),
    action TEXT NOT NULL,
    user_email TEXT,
    details JSONB DEFAULT '{}'::jsonb
);

-- Row Level Security (RLS) Configuration Policies
ALTER TABLE public.inquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mandi_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.compliance_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.forex_exposure ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lc_discrepancies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.incentive_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Tenant-Scoped Policies for Private CRM Transactions
CREATE POLICY "Allow tenant read access on inquiries" ON public.inquiries FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
CREATE POLICY "Allow tenant modification on inquiries" ON public.inquiries FOR ALL USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Allow tenant read access on shipments" ON public.shipments FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
CREATE POLICY "Allow tenant modification on shipments" ON public.shipments FOR ALL USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Allow tenant read access on compliance_checks" ON public.compliance_checks FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
CREATE POLICY "Allow tenant modification on compliance_checks" ON public.compliance_checks FOR ALL USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Allow tenant read access on forex_exposure" ON public.forex_exposure FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
CREATE POLICY "Allow tenant modification on forex_exposure" ON public.forex_exposure FOR ALL USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Allow tenant read access on lc_discrepancies" ON public.lc_discrepancies FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
CREATE POLICY "Allow tenant modification on lc_discrepancies" ON public.lc_discrepancies FOR ALL USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Allow tenant read access on incentive_claims" ON public.incentive_claims FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
CREATE POLICY "Allow tenant modification on incentive_claims" ON public.incentive_claims FOR ALL USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Allow tenant read access on audit_logs" ON public.audit_logs FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
CREATE POLICY "Allow tenant insertion on audit_logs" ON public.audit_logs FOR INSERT WITH CHECK (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

-- Global Reference Read-only Policies
CREATE POLICY "Allow global read access on mandi_rates" ON public.mandi_rates FOR SELECT USING (true);
CREATE POLICY "Allow global admin modification on mandi_rates" ON public.mandi_rates FOR ALL USING (true);

-- 9. Seasonal Global Demand Index Heatmap (Global Reference Data)
CREATE TABLE IF NOT EXISTS public.market_intel_heatmap (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    product TEXT NOT NULL,
    destinations JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 10. Customs Duty & Import Compliance (Global Reference Data)
CREATE TABLE IF NOT EXISTS public.market_intel_compliance (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    route TEXT NOT NULL,
    duty TEXT NOT NULL,
    certs TEXT NOT NULL,
    risk TEXT NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 11. Landed Cost Spreads & Competitor Comparison (Global Reference Data)
CREATE TABLE IF NOT EXISTS public.market_intel_landed_spreads (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    product TEXT NOT NULL,
    dest TEXT NOT NULL,
    inr_landed TEXT NOT NULL,
    competitor_landed TEXT NOT NULL,
    quote TEXT NOT NULL,
    fit TEXT NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 12. B2B Discovered Importer Prospects
CREATE TABLE IF NOT EXISTS public.discovered_prospects (
    id TEXT PRIMARY KEY,
    tenant_id UUID DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
    name TEXT NOT NULL,
    country TEXT NOT NULL,
    product TEXT NOT NULL,
    score INT NOT NULL,
    email TEXT,
    status TEXT DEFAULT 'New' CHECK (status IN ('New', 'Approved', 'Rejected')),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 13. App configuration settings persisted from the admin UI
CREATE TABLE IF NOT EXISTS public.app_settings (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS Enablement for Phase 3 Tables
ALTER TABLE public.market_intel_heatmap ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_intel_compliance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_intel_landed_spreads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.discovered_prospects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

-- Policies for Reference & Prospect Tables
CREATE POLICY "Allow global read on market_intel_heatmap" ON public.market_intel_heatmap FOR SELECT USING (true);
CREATE POLICY "Allow modification on market_intel_heatmap" ON public.market_intel_heatmap FOR ALL USING (true);

CREATE POLICY "Allow global read on market_intel_compliance" ON public.market_intel_compliance FOR SELECT USING (true);
CREATE POLICY "Allow modification on market_intel_compliance" ON public.market_intel_compliance FOR ALL USING (true);

CREATE POLICY "Allow global read on market_intel_landed_spreads" ON public.market_intel_landed_spreads FOR SELECT USING (true);
CREATE POLICY "Allow modification on market_intel_landed_spreads" ON public.market_intel_landed_spreads FOR ALL USING (true);

CREATE POLICY "Allow tenant read access on discovered_prospects" ON public.discovered_prospects FOR SELECT USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
CREATE POLICY "Allow tenant modification on discovered_prospects" ON public.discovered_prospects FOR ALL USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);

CREATE POLICY "Allow public read on app_settings" ON public.app_settings FOR SELECT USING (true);
CREATE POLICY "Allow public insert on app_settings" ON public.app_settings FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on app_settings" ON public.app_settings FOR UPDATE USING (true);
