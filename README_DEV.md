# DEVELOPER NOTES — Protected Modules

## 🔒 LOCKED MODULES (DO NOT MODIFY)

### lib/features/home_locked/
**Status:** LOCKED  
**Last Updated:** 2026-01-10  

This folder contains the "Tarjeta de Inicio" (Home Start Block) which is considered **STABLE**.

**Rules:**
- ❌ DO NOT modify any file in this folder
- ❌ DO NOT change imports, styles, or navigation
- ❌ DO NOT include in bulk refactors

**If changes ARE needed:**
1. Create a new backup version in `BACKUPS_UI/HOME_CARD_LOCKED/v2/`
2. Document the reason for changes
3. Test thoroughly before deploying

**Restore from backup:**
```powershell
Remove-Item lib\features\home_locked -Recurse
Copy-Item BACKUPS_UI\HOME_CARD_LOCKED\v1\lib\features\home_locked lib\features\ -Recurse
```
