# 📖 Active Directory Admin Playbook (Pied Piper Edition)

This playbook documents essential Active Directory admin tasks inside your **Pied Piper Lab**.  
All steps are paired with screenshots for a beginner-friendly, “dummy proof” walkthrough.  

---

## 📜 Table of Contents

- [📁 Step 1. Create Organizational Units (OUs)](#-step-1-create-organizational-units-ous)
- [👤 Step 2. Create User Accounts](#-step-2-create-user-accounts)
- [👥 Step 3. Create Security Groups](#-step-3-create-security-groups)
- [🔗 Step 4. Add Users to Groups](#-step-4-add-users-to-groups)
- [🖥️ Step 5. Move CLIENT01 into the Correct OU](#-step-5-move-client01-into-the-correct-ou)
- [🧰 Step 6. Reset a User Password](#-step-6-reset-a-user-password)
- [🧱 Step 7. Create and Link a GPO (Pied Piper Banner)](#-step-7-create-and-link-a-gpo-pied-piper-banner)
- [🧪 Step 8. Push and Test the GPO](#-step-8-push-and-test-the-gpo)
- [📦 Wrapping Up](#-wrapping-up)

---

## 📁 Step 1. Create Organizational Units (OUs)

1. Open **Server Manager** → **Tools** → hover over **Active Directory Users and Computers (ADUC)**.  
   ![Step 1](images/playbook/001.png)

2. In **ADUC**, right-click `ToonWrld.local` → hover over **New > Organizational Unit**.  
   ![Step 2](images/playbook/002.png)

3. Create a top-level OU named **Departments**.  
   - “Protect container from accidental deletion” left checked.  
   ![Step 3](images/playbook/003.png)

4. Right-click **Departments** → hover over **New > Organizational Unit**.  
   ![Step 4](images/playbook/004.png)

5. Create a child OU named **Engineering**.  
   ![Step 5](images/playbook/005.png)

6. Create a child OU named **Compression**.  
   ![Step 6](images/playbook/006.png)

7. Create a child OU named **Business**.  
   ![Step 7](images/playbook/007.png)

---

## 👤 Step 2. Create User Accounts

8. Right-click the **Engineering OU** → hover over **New > User**.  
   ![Step 8](images/playbook/008.png)

9. Create **Bertram Gilfoyle** (`bertram.gilfoyle@ToonWrld.local`).  
   ![Step 9](images/playbook/009.png)

10. Assign a password for Gilfoyle.  
   - “User must change password at next logon” checked.  
   ![Step 10](images/playbook/010.png)

11. Confirm Gilfoyle’s account creation.  
   ![Step 11](images/playbook/011.png)

12. Create **Dinesh Chugtai** (`dinesh.chugtai@ToonWrld.local`).  
   ![Step 12](images/playbook/012.png)

13. Assign a password for Dinesh.  
   ![Step 13](images/playbook/013.png)

14. Confirm Dinesh’s account creation.  
   ![Step 14](images/playbook/014.png)

15. Create **Richard Hendricks** (`richard.hendricks@ToonWrld.local`) in the **Compression OU**.  
   ![Step 15](images/playbook/015.png)

16. Create **Jared Dunn** (`jared.dunn@ToonWrld.local`) in the **Business OU**.  
   ![Step 16](images/playbook/016.png)

---

## 👥 Step 3. Create Security Groups

17. Engineering OU with Bertram and Dinesh listed. Right-click **Engineering** → **New > Group**.  
   ![Step 17](images/playbook/017.png)

18. Create group named **Engineers**.  
   ![Step 18](images/playbook/018.png)

19. In **Compression OU**, right-click → **New > Group**.  
   ![Step 19](images/playbook/019.png)

20. Create group named **CompressionTeam**.  
   ![Step 20](images/playbook/020.png)

21. In **Business OU**, create group **BizOps**.  
   ![Step 21](images/playbook/021.png)

---

## 🔗 Step 4. Add Users to Groups

22. In **Engineering OU**, right-click **Dinesh Chugtai** → **Add to a group**.  
   ![Step 22](images/playbook/022.png)

23. In “Select Groups” dialog, type `Engi` → click **Check Names**.  
   ![Step 23](images/playbook/023.png)

24. Auto-completes to **Engineers** group → click OK.  
   ![Step 24](images/playbook/024.png)

25. Confirmation message shows **Dinesh added successfully**.  
   ![Step 25](images/playbook/025.png)

26. In **Compression OU**, right-click **Richard Hendricks** → **Add to a group**.  
   ![Step 26](images/playbook/026.png)

27. In “Select Groups,” type `Comp` → click **Check Names**.  
   ![Step 27](images/playbook/027.png)

28. Auto-completes to **CompressionTeam** group → click OK.  
   ![Step 28](images/playbook/028.png)

29. Confirmation message shows **Richard added successfully**.  
   ![Step 29](images/playbook/029.png)

30. In **Business OU**, add **Jared Dunn** → auto-completes to **BizOps** group → click OK.  
   ![Step 30](images/playbook/030.png)

---

## 🖥️ Step 5. Move CLIENT01 into the Correct OU

31. In **ADUC**, open the **Computers** container and select **CLIENT01**.  
   ![Step 31](images/playbook/031.png)

32. Right-click **CLIENT01** → **Move…**.  
   ![Step 32](images/playbook/032.png)

33. In the tree, select **Departments > Engineering OU** → click OK.  
   ![Step 33](images/playbook/033.png)

34. Confirm **CLIENT01** is now listed inside **Engineering OU**.  
   ![Step 34](images/playbook/034.png)

---

## 🧰 Step 6. Reset a User Password

35. In **ADUC**, right-click **Dinesh Chugtai** → **Reset Password…**.  
   ![Step 35](images/playbook/035.png)

⚠️ **Important:** Always have the user log in at least once before forcing a password reset. Resetting before first logon can cause an infinite loop.

36. In the Reset Password dialog, fill in **New Password** and **Confirm Password**.  
   - Uncheck: *User must change password at next logon*.  
   ![Step 36](images/playbook/036.png)

37. Confirmation shows password reset successfully.  
   ![Step 37](images/playbook/037.png)

---

## 🧱 Step 7. Create and Link a GPO (Pied Piper Banner)

38. Open **Server Manager** → **Tools > Group Policy Management**.  
   ![Step 38](images/playbook/038.png)

39. In GPM, right-click **Engineering OU** → **Create a GPO in this domain, and Link it here…**  
   ![Step 39](images/playbook/039.png)

40. Name the new GPO: **Pied Piper Banner**.  
   ![Step 40](images/playbook/040.png)

41. Right-click **Pied Piper Banner** → **Edit**.  
   ![Step 41](images/playbook/041.png)

42. In GPO Editor, navigate to **Security Options**.  
   ![Step 42](images/playbook/042.png)

43. Set **Message title** to *Pied Piper Security Notice*.  
   ![Step 43](images/playbook/043.png)

44. Set **Message text**.  
   ![Step 44](images/playbook/044.png)

45. Example message:  
![Step 45](images/playbook/045.png)

---

## 🧪 Step 8. Push and Test the GPO

46. Back in **Group Policy Management**.  
![Step 46](images/playbook/046.png)

47. Right-click **Engineering OU** → **Group Policy Update…**.  
![Step 47](images/playbook/047.png)

48. Confirm update.  
![Step 48](images/playbook/048.png)

49. On CLIENT01 login screen → **Other user** → log in as Dinesh.  
![Step 49](images/playbook/049.png)

50. Prompt: must change password.  
![Step 50](images/playbook/050.png)

51. Enter old + new password.  
![Step 51](images/playbook/051.png)

52. 🎉 Success! Pied Piper Security Notice displayed.  
![Step 52](images/playbook/052.png)

---

## 📦 Wrapping Up

In this playbook you:  
- Created OUs for **Engineering, Compression, Business**  
- Added users (`Gilfoyle`, `Dinesh`, `Richard`, `Jared`)  
- Built groups (`Engineers`, `CompressionTeam`, `BizOps`)  
- Moved CLIENT01 into Engineering OU  
- Reset a password safely  
- Created, linked, and tested a **Pied Piper logon banner GPO**

📐 **Blueprint complete:** You’ve covered the most common AD tasks that every junior sysadmin and helpdesk tech should know.

[🔝 Back to Top](#top)
