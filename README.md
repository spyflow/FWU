# F\*ck You Windows Update

**Autor:** spyflow

---

## Uso

```powershell
irm https://fwu.spyflow.tech/fyw.ps1 | iex
```

## Funcionamiento

1. El script se asegura de ejecutarse con **permisos de administrador** mediante auto-elevación.
2. Modifica las claves de registro de Windows Update para establecer una pausa por el número de días que elijas.
3. Permite pausar por períodos predefinidos (1 semana, 1 mes, 3 meses, 6 meses, 1 año) o un número de días personalizado.
4. Incluye la opción de **reanudar actualizaciones** manualmente.


