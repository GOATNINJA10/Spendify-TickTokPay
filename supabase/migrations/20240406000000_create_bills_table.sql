-- Create bills table
CREATE TABLE IF NOT EXISTS public.bills (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    is_paid BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Add RLS policies
ALTER TABLE public.bills ENABLE ROW LEVEL SECURITY;

-- Policy for users to view their own bills
CREATE POLICY "Users can view their own bills"
    ON public.bills
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy for users to insert their own bills
CREATE POLICY "Users can insert their own bills"
    ON public.bills
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy for users to update their own bills
CREATE POLICY "Users can update their own bills"
    ON public.bills
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Policy for users to delete their own bills
CREATE POLICY "Users can delete their own bills"
    ON public.bills
    FOR DELETE
    USING (auth.uid() = user_id);

-- Create index for faster queries
CREATE INDEX bills_user_id_idx ON public.bills(user_id);
CREATE INDEX bills_due_date_idx ON public.bills(due_date); 