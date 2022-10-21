--Transaction

--Örnek
--İki adet banka tablosunu oluşturalım. Bankalar arası havale işlemi gerçekleştirelim. Ve bu işlemleri yaparken
--transaction kullanalım.

Create Database BankaDb --önce işlemleri yapacağımız BankaDb isimli database'i oluşturalım.
Go
Use BankaDb --Ardından use komutu ile bu database'i seçtirelim.
Go

Create Table ABanka
(
	HesapNo int,
	Bakiye money
)
Go
Create Table BBanka
(
	HesapNo int,
	Bakiye money
)
Go
Insert ABanka Values(10, 1000),
					(20, 2500)
Insert BBanka Values(30, 2300),
					(40, 760)
Go
Create Proc sp_HavaleYap --4 tane parametre alan bir Stored Procedure 
(
	@BankaKimden nvarchar(MAX),
	@GonderenHesapNo int,
	@AlanHesapNo int,
	@Tutar money
)
as
Begin Transaction Kontrol --SP'mizin komut kısmında Begin Transaction komutuyla Kontrol isimli bir Transaction devreye sokulmakta,
Declare @ABakiye int, @BBakiye int, @HesaptakiPara money
If @BankaKimden = 'ABanka' --@BankaKimden parametresine gelen benka ABanka ise bu bloktaki işlemleri yap. Değilse Else bloğu.
Begin
	Select @HesaptakiPara = Bakiye from ABanka Where HesapNo = @GonderenHesapNo --gönderecek olan kişinin hesap numarasına göre bir sorgulama yapıyoruz.
	If @Tutar>@HesaptakiPara													--ve bu kişinin hesaptaki parasını elde ediyoruz.
	Begin
		print CAST(@GonderenHesapNo as nvarchar(MAX)) + ' numaralı hesapta gönderilmek istenen tutardan daha az para mevcuttur.'
		Rollback --İşlemleri geri al.
	End
	Else
	Begin
		Update ABanka Set Bakiye = Bakiye - @Tutar Where HesapNo = @GonderenHesapNo
		Update BBanka Set Bakiye = Bakiye + @Tutar Where HesapNo = @AlanHesapNo

		print 'ABankasındaki '+ CAST(@GonderenHesapNo as nvarchar(MAX)) + ' numaralı hesaptan BBankasındaki ' + CAST(@AlanHesapNo as nvarchar(MAX))
		+ ' numaralı hesaba ' + CAST (@Tutar as nvarchar(MAX)) + ' değerinde para havale edilmiştir.'
		print 'Son değerler;'

		Select @ABakiye = Bakiye from ABanka where HesapNo = @GonderenHesapNo
		Select @BBakiye = Bakiye from BBanka where HesapNo = @AlanHesapNo

		print 'ABankasındaki ' + CAST(@AlanHesapNo as nvarchar(MAX)) + ' numaralı hesapta kalan bakiye: ' + CAST(@ABakiye as nvarchar(MAX))
		print 'BBankasındaki ' + CAST(@GonderenHesapNo as nvarchar(MAX)) + ' numaralı hesapta kalan bakiye: ' + CAST(@BBakiye as nvarchar(MAX))
		
		Commit
	End
End
Else
	Begin
	Select @HesaptakiPara = Bakiye from BBanka Where HesapNo = @GonderenHesapNo 
	If @Tutar>@HesaptakiPara													
	Begin
		print CAST(@GonderenHesapNo as nvarchar(MAX)) + ' numaralı hesapta gönderilmek istenen tutardan daha az para mevcuttur.'
		Rollback --İşlemleri geri al.
	End
	Else
	Begin
		Update BBanka Set Bakiye = Bakiye - @Tutar Where HesapNo = @GonderenHesapNo
		Update ABanka Set Bakiye = Bakiye + @Tutar Where HesapNo = @AlanHesapNo

		print 'BBankasındaki '+ CAST(@GonderenHesapNo as nvarchar(MAX)) + ' numaralı hesaptan ABankasındaki ' + CAST(@AlanHesapNo as nvarchar(MAX))
		+ ' numaralı hesaba ' + CAST (@Tutar as nvarchar(MAX)) + ' değerinde para havale edilmiştir.'
		print 'Son değerler;'

		Select @BBakiye = Bakiye from BBanka where HesapNo = @GonderenHesapNo
		Select @ABakiye = Bakiye from ABanka where HesapNo = @AlanHesapNo

		print 'ABankasındaki ' + CAST(@AlanHesapNo as nvarchar(MAX)) + ' numaralı hesapta kalan bakiye: ' + CAST(@ABakiye as nvarchar(MAX))
		print 'BBankasındaki ' + CAST(@GonderenHesapNo as nvarchar(MAX)) + ' numaralı hesapta kalan bakiye: ' + CAST(@BBakiye as nvarchar(MAX))
		
		Commit
	End
End

Exec sp_HavaleYap 'ABanka', 10, 30, 100 --A Bankasından 10. hesaptan 30. hesaba 100 değerinde para gönder

Exec sp_HavaleYap 'BBanka', 30, 10, 300

Exec sp_HavaleYap 'ABanka', 20, 40, 10000

Exec sp_HavaleYap 'BBanka', 40, 20, 10000