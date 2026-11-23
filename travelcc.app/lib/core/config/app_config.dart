/// Configuración central de la app. Todo lo que cambia entre PCs o entornos va aquí.
class AppConfig {
  // Supabase: en el panel, Project Settings > API.
  // Usa la clave PÚBLICA (publishable / anon).
  // NUNCA pongas aquí la clave "secret" del backend.
  static const supabaseUrl = 'https://ljikrazxqhyesobvmpwh.supabase.co';
  static const supabaseAnonKey = 'sb_publishable_Mw9xGwCAK1ckJ013zzUfBA_Q4AP2lMG';

  // Dirección de tu backend (incluye /api/v1, sin barra final).
  //  - Celular por Wi-Fi:  http://IP_DE_TU_PC:3000/api/v1   (ej. http://192.168.1.20:3000/api/v1)
  //  - Celular por USB con "adb reverse tcp:3000 tcp:3000":  http://localhost:3000/api/v1
  static const String baseUrl = 'https://TU-SERVICIO.onrender.com/api/v1';
}
