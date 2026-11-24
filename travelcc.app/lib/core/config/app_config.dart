/// Configuración central de la app. Todo lo que cambia entre PCs o entornos va aquí.
class AppConfig {
  // Supabase: en el panel, Project Settings > API.
  // Usa la clave PÚBLICA (publishable / anon).
  // NUNCA pongas aquí la clave "secret" del backend.
  static const supabaseUrl = 'https://ljikrazxqhyesobvmpwh.supabase.co';
  static const supabaseAnonKey = 'sb_publishable_Mw9xGwCAK1ckJ013zzUfBA_Q4AP2lMG';

  // Dirección de tu backend (incluye /api/v1, sin barra final).
  static const apiBaseUrl = 'https://travelcc.onrender.com/api/v1';
  static const baseUrl = apiBaseUrl;
}
