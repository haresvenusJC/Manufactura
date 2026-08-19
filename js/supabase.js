import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm';

// Credenciales configuradas para el proyecto de Hares de México
const SUPABASE_URL = 'https://snknvjactmdoyiqnqiij.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNua252amFjdG1kb3lpcW5xaWlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY5OTAyNzQsImV4cCI6MjEwMjU2NjI3NH0.azyLEufoXFEmaNnN8_hVIgVwMumeO7VTzOMi9xXSH50';

export const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);