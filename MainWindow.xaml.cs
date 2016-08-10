//using Microsoft.Win32;
using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.ServiceProcess;
using System.Threading;
using System.Windows;
using System.Windows.Forms;

namespace AssistenteMigracao
{
    /// <summary>
    /// Interaction SetHistic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        BackgroundWorker InstallPostgres = new BackgroundWorker();
        bool SO64bits;
        string password = "";
        string SourcePath = "C:\\DeMaria\\BD9.5";
        string OdlPath = "C:\\DeMaria\\BD";
        string ServiceName = "PostgresSQL9.5-DeMaria";
        public MainWindow()
        {
            InitializeComponent();

            AppDomain currentDomain = AppDomain.CurrentDomain;
            currentDomain.UnhandledException += new UnhandledExceptionEventHandler(MyHandler);

            InstallPostgres.DoWork += MyWorker_DoWork;
            InstallPostgres.WorkerSupportsCancellation = true;
            SO64bits = (IntPtr.Size == 8);



        }

        static void MyHandler(object sender, UnhandledExceptionEventArgs args)
        {
            Exception e = (Exception)args.ExceptionObject;
            System.Windows.Forms.MessageBox.Show("MyHandler caught : " + e.Message);
        }

        private void MyWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            try
            {
                SetHist(password);

                if (!InstalacaoPostgresSql())
                    CANCELA();
                else
                {
                    SetProgress(30);
                    if (!_BackupBD() || !_Restore() || !_ExecutaSql())
                        CANCELA();
                    else
                    {
                        SetProgress(100);
                        CONCLUIDO();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show(ex.Message);
            }
        }

        public bool _ExecutaSql()
        {
            SetProgress(90);

            try
            {
                string fileTem = Path.GetTempPath() + Path.GetFileNameWithoutExtension(Path.GetTempFileName()) + ".sql";
                File.WriteAllText(fileTem, Properties.Resources.UPDATE_2017, System.Text.Encoding.Default);

                Environment.SetEnvironmentVariable("PGPASSWORD", password);

                SetHist("Executando scrip de atualização da versão 2017...");
                ProcessStartInfo psUser = new ProcessStartInfo();
                psUser.FileName = SourcePath + "\\bin\\psql.exe";
               
                psUser.Arguments = $"-U postgres -d docwin -p5433 -L\"{fileTem + ".txt"}\" -f \"{fileTem}\"";
               

                SetHist("Iniciando...");

                Process proRESTUsr = Process.Start(psUser);
                SetHist("Executando...");

                proRESTUsr.WaitForExit();
                                           
                proRESTUsr.Dispose();

                Thread.Sleep(1000);
                File.Delete(fileTem);
            }
            catch (Exception ex)
            {
                Dispatcher.Invoke(new Action(() =>
                {
                    System.Windows.Forms.MessageBox.Show(ex.Message);
                }));
                SetHist(ex.Message);
                return false;
            }
            finally
            {
                Environment.SetEnvironmentVariable("PGPASSWORD", string.Empty);
            }

            return true;
        }

        public static void RestartService(string serviceName, int timeoutMilliseconds)
        {
            ServiceController service = new ServiceController(serviceName);
            try
            {
                int millisec1 = Environment.TickCount;
                TimeSpan timeout = TimeSpan.FromMilliseconds(timeoutMilliseconds);

                service.Stop();
                service.WaitForStatus(ServiceControllerStatus.Stopped, timeout);

                // count the rest of the timeout
                int millisec2 = Environment.TickCount;
                timeout = TimeSpan.FromMilliseconds(timeoutMilliseconds - (millisec2 - millisec1));

                service.Start();
                service.WaitForStatus(ServiceControllerStatus.Running, timeout);
            }
            catch (Exception ex)
            {
                string msg = ex.Message;
            }
        }

        private void SetProgress(int value)
        {
            Dispatcher.BeginInvoke((Action)delegate ()
            {
                pgrTotal.Value = value;
            });
        }

        private void CANCELA()
        {
            Dispatcher.BeginInvoke((Action)delegate ()
            {
                SetHist("Instalação cancelada...");
                pgrIndeterminate.IsIndeterminate = false;
                pgrTotal.Value = 0;
                InstallPostgres.CancelAsync();
                InstallPostgres.Dispose();
            });
        }

        private void CONCLUIDO()
        {
            Dispatcher.BeginInvoke((Action)delegate ()
            {
                SetHist("Operação finalizada!");
                pgrIndeterminate.IsIndeterminate = false;
                pgrTotal.Value = 0;
                InstallPostgres.CancelAsync();
                lblHist.Visibility = Visibility.Hidden;
                txtFinalize.Text = txtFinalize.Text.Replace("{SOURCEDIR}", SourcePath);
                txtFinalize.Visibility = Visibility.Visible;
            });
        }

        private void SetHist(string value)
        {
            Dispatcher.BeginInvoke((Action)delegate ()
            {
                lblHist.Text += value + "\r\n";
                lblInfo.Content = value;
            });
        }

        private void btnIniciar_Click_1(object sender, RoutedEventArgs e)
        {
            if (AbreInfo())
            {
                grdOpcoesPastas.Visibility = Visibility.Collapsed;
                label1_Copy1.Visibility = Visibility.Collapsed;
                lblInfo.Content = "Inicializando migração para versão 2017 do DOC-Windows...";
                pgrTotal.Value = 10;
                pgrIndeterminate.IsIndeterminate = true;
                btnIniciar.Visibility = Visibility.Collapsed;
                lblInfo.Content = "Instalando novo banco de dados...";
                InstallPostgres.RunWorkerAsync();
            }
        }

        public bool InstalacaoPostgresSql()
        {
            if (File.Exists(Path.GetDirectoryName(Assembly.GetEntryAssembly().Location) + "\\PostgresSQL\\postgresql-9.5.2-1-windows" + (SO64bits ? "-x64.exe" : ".exe")))
            {
                SetProgress(10);
                SetHist("Postgres 9.5 em " + SourcePath);
                SetHist("Instalando banco de dados...");
                ProcessStartInfo psiC = new ProcessStartInfo();
                psiC.FileName = Path.GetDirectoryName(Assembly.GetEntryAssembly().Location) + "\\PostgresSQL\\postgresql-9.5.2-1-windows" + (SO64bits ? "-x64.exe" : ".exe");
                psiC.Arguments = " --mode unattended --create_shortcuts 0 --prefix \"" + SourcePath + "\" --datadir \"" + SourcePath + "\\data\" --servicename " + ServiceName + " --superpassword " + password + " --serverport 5433  --locale \"Portuguese, Brazil\"";
                psiC.UseShellExecute = false;
                psiC.CreateNoWindow = true;
                psiC.RedirectStandardError = true;
                psiC.RedirectStandardOutput = true;
                Process proCOMP = Process.Start(psiC);
                proCOMP.WaitForExit();

                if (proCOMP.ExitCode != 0)
                {
                    string _erro = proCOMP.StandardError.ReadToEnd();
                    SetHist(_erro);
                    string _erros = proCOMP.StandardOutput.ReadToEnd();
                    return false;
                }
                else
                {
                    SetHist("Instalação concluida!");
                }
                SetProgress(20);
                SetHist("Alterando configurações de privilégios...");

                string str = File.ReadAllText(SourcePath + "\\data\\postgresql.conf");
                Thread.Sleep(2000);
                File.WriteAllText(SourcePath + "\\data\\postgresql.conf", str.Replace("#lo_compat_privileges = off", "lo_compat_privileges = on"));

                SetHist("Reiniciando serviço!");

                RestartService(ServiceName, 1000 * 120);

                return true;
            }
            else
            {
                SetHist($"O arquivo {Path.GetDirectoryName(Assembly.GetEntryAssembly().Location) + "\\PostgresSQL\\postgresql-9.5.2-1-windows" + (SO64bits ? "-x64.exe" : ".exe")} não foi encontrado.");
                return false;
            }
        }

        private bool _BackupBD()
        {
            try
            {
                string dir = Path.GetTempPath() + "MigracaoDOC17\\";

                if (!Directory.Exists(dir))
                    Directory.CreateDirectory(dir);
                else
                {
                    Directory.Delete(dir, true);
                    Directory.CreateDirectory(dir);
                }

                Environment.SetEnvironmentVariable("PGPASSWORD", password);

                if (!File.Exists(SourcePath + "\\bin\\pg_dump.exe"))
                {
                    SetHist($"O arquivo {SourcePath + "\\bin\\pg_dump.exe"} não foi encontrado.");
                    return false;
                }

                //Exportando somente os dados sem schemas.
                SetHist("Realizando backup dos dados(8.3)...");
                ProcessStartInfo psi = new ProcessStartInfo();
                psi.RedirectStandardOutput = false;
                psi.FileName = SourcePath + "\\bin\\pg_dump.exe";
                psi.RedirectStandardOutput = false;
                psi.Arguments = "-a -b -Fc -U postgres -p 5432 -f \"" + dir + "data.dmp\"" + " docwin";
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;
                psi.RedirectStandardError = true;
                Process procData = Process.Start(psi);
                procData.WaitForExit();
                SetProgress(40);
                if (procData.ExitCode != 0)
                {
                    string _erro = procData.StandardError.ReadToEnd();
                    SetHist(_erro);
                    return false;
                }

                if (File.Exists(dir + "data.dmp"))
                {
                    FileInfo flinfo = new FileInfo(dir + "data.dmp");
                    if (flinfo.Length < 15000000)
                    {
                        return false;
                    }
                }

                //Exportando somente os schemas sem os dados
                SetHist("Realizando backup dos schemas(8.3)...");
                psi = new ProcessStartInfo();
                psi.FileName = SourcePath + "\\bin\\pg_dump.exe";
                psi.RedirectStandardOutput = false;
                psi.Arguments = "-s -Fc -p 5432 -U postgres -f \"" + dir + "schemas.dmp\"" + " docwin";
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;
                psi.RedirectStandardError = true;
                Process procSchema = Process.Start(psi);
                procSchema.WaitForExit();

                if (procSchema.ExitCode != 0)
                    SetHist(procSchema.StandardError.ReadToEnd());

                if (!File.Exists(SourcePath + "\\bin\\pg_dumpall.exe"))
                {
                    SetHist($"O arquivo {SourcePath + "\\bin\\pg_dumpall.exe"} não foi encontrado.");
                    return false;
                }
                SetProgress(50);
                //Exportando os dados de usuários
                SetHist("Realizando backup dos usuários(8.3)...");
                psi = new ProcessStartInfo();
                psi.FileName = SourcePath + "\\bin\\pg_dumpall.exe";
                psi.RedirectStandardOutput = false;
                psi.Arguments = "-U postgres -p 5432 --globals-only -f \"" + dir + "globals.dmp\"";
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;
                psi.RedirectStandardError = true;
                Process procGlobals = Process.Start(psi);
                procGlobals.WaitForExit();

                if (procGlobals.ExitCode != 0)
                    SetHist(procGlobals.StandardError.ReadToEnd());

                SetHist("Copiando pasta de backup...");

                if (!Directory.Exists(SourcePath + "\\backup"))
                {
                    Directory.CreateDirectory(SourcePath + "\\backup");
                    Directory.GetFiles(OdlPath + "\\backup").ToList().ForEach(f => File.Copy(f, SourcePath + "\\backup\\" + (new FileInfo(f)).Name, true));
                }

                if (!File.Exists(SourcePath + "\\backup\\7za.exe"))
                {
                    SetHist($"O arquivo {SourcePath + "\\backup\\7za.exe"} não foi encontrado.");
                    return false;
                }

                //SetHist("Compactando arquivos...");
                //ProcessStartInfo psiC = new ProcessStartInfo();
                //psiC.FileName = SourcePath + "\\backup\\7za.exe";
                //psiC.RedirectStandardOutput = false;

                //SaveFileDialog sfdBackup = new SaveFileDialog();
                //sfdBackup.DefaultExt = "csd";
                //sfdBackup.FileName = "backupMigração8.3.csd";
                //sfdBackup.Filter = "DOC-Backup(*.csd)|*.csd";
                //sfdBackup.Title = "Salve a cópia de segurança em um local seguro";
                //System.Windows.Forms.DialogResult dia = System.Windows.Forms.DialogResult.Cancel;

                //Dispatcher.Invoke(new Action(() =>
                //{
                //    dia = sfdBackup.ShowDialog();
                //}));

                //if (dia == System.Windows.Forms.DialogResult.OK)
                //{
                //    psiC.Arguments = "a -y \"" + SourcePath + "\\backupMigração8.3.csd\" \"" + dir + "*.*\"";
                //    psiC.UseShellExecute = false;
                //    psiC.CreateNoWindow = true;
                //    psiC.RedirectStandardError = true;

                //    Process proCOMP = Process.Start(psiC);
                //    proCOMP.WaitForExit();

                //    if (proCOMP.ExitCode != 0)
                //        return false;
                //    else
                //        File.Copy(SourcePath + "\\backupMigração8.3.csd", sfdBackup.FileName, true);

                //}
                //else
                //    return false;
            }
            catch (Exception ex)
            {
                Dispatcher.Invoke(new Action(() =>
                {
                    System.Windows.Forms.MessageBox.Show(ex.Message);
                }));
                SetHist(ex.Message);
                return false;
            }
            finally
            {
                Environment.SetEnvironmentVariable("PGPASSWORD", string.Empty);
            }
            return true;
        }

        private bool _Restore()
        {
            SetProgress(60);

            try
            {
                string dir = Path.GetTempPath() + "MigracaoDOC17\\";

                if (Directory.Exists(dir))
                {
                    if (true)
                    {
                        Environment.SetEnvironmentVariable("PGPASSWORD", password);

                        int rt = 0, i = 0;
                        string errorProc = "";

                        errorProc = "";
                        if (!File.Exists(SourcePath + "\\bin\\psql.exe"))
                        {
                            SetHist($"O arquivo {SourcePath + "\\bin\\psql.exe"} não foi encontrado.");
                            return false;
                        }
                        if (!File.Exists(dir + "globals.dmp"))
                        {
                            SetHist($"O arquivo {dir + "globals.dmp"} não foi encontrado.");
                            return false;
                        }

                        //Restaurando os usuários
                        Process proRESTUsr = new Process();
                        SetHist("Restaurando usuários(9.5)...");
                        ProcessStartInfo psUser = new ProcessStartInfo();
                        psUser.FileName = SourcePath + "\\bin\\psql.exe";
                        psUser.RedirectStandardOutput = false;
                        psUser.Arguments = "-p 5433 -U postgres -f " + "\"" + dir + "globals.dmp" + "\"";
                        psUser.UseShellExecute = false;
                        psUser.CreateNoWindow = true;
                        psUser.RedirectStandardError = true;


                        proRESTUsr = Process.Start(psUser);
                        proRESTUsr.WaitForExit();

                        if (proRESTUsr.ExitCode != 0)
                            SetHist(proRESTUsr.StandardError.ReadToEnd());

                        if (!File.Exists(dir + "schemas.dmp"))
                        {
                            SetHist($"O arquivo {dir + "schemas.dmp"} não foi encontrado.");
                            return false;
                        }
                        if (!File.Exists(SourcePath + "\\bin\\pg_restore.exe"))
                        {
                            SetHist($"O arquivo {SourcePath + "\\bin\\pg_restore.exe"} não foi encontrado.");
                            return false;
                        }
                        //Restaurando os schemas
                        do
                        {
                            SetHist(string.Format("{" + i + "}", "Restaurando schemas(9.5)...", "Tentando restaurar novamente..."));
                            ProcessStartInfo psi = new ProcessStartInfo();
                            psi.FileName = SourcePath + "\\bin\\pg_restore.exe";
                            psi.RedirectStandardOutput = false;
                            psi.Arguments = "-C -s -e -p 5433 -U postgres -d postgres \"" + dir + "schemas.dmp" + "\"";
                            psi.UseShellExecute = false;
                            psi.CreateNoWindow = true;
                            psi.RedirectStandardError = true;
                            Process proREST = Process.Start(psi);
                            proREST.WaitForExit();
                            errorProc = proREST.StandardError.ReadToEnd();
                            rt = proREST.ExitCode;
                            i++;
                        } while (rt > 0 && i < 2);

                        if (rt > 0)
                        {
                            System.Windows.MessageBox.Show("Não foi possível restaurar os schemas do banco de dados. Messagem retornada:\r\n" + errorProc, "A T E N Ç Ã O", MessageBoxButton.OK, MessageBoxImage.Error);
                            return false;
                        }
                        if (!File.Exists(SourcePath + "\\bin\\vacuumlo.exe"))
                        {
                            SetHist($"O arquivo {SourcePath + "\\bin\\vacuumlo.exe"} não foi encontrado.");
                            return false;
                        }
                        SetProgress(70);
                        //Executando vacuum no Oid
                        SetHist("Limpando large object(9.5)...");
                        ProcessStartInfo psVCCMLO = new ProcessStartInfo();
                        psVCCMLO.FileName = SourcePath + "\\bin\\vacuumlo.exe";
                        psVCCMLO.RedirectStandardOutput = false;
                        psVCCMLO.Arguments = "-p 5433 -U postgres docwin";
                        psVCCMLO.UseShellExecute = false;
                        psVCCMLO.CreateNoWindow = true;
                        psVCCMLO.RedirectStandardError = true;
                        Process proVCCMLO = Process.Start(psVCCMLO);
                        proVCCMLO.WaitForExit();
                        SetProgress(80);
                        if (proVCCMLO.ExitCode != 0)
                            SetHist(proVCCMLO.StandardError.ReadToEnd());
                        if (!File.Exists(dir + "data.dmp"))
                        {
                            SetHist($"O arquivo { dir + "data.dmp"} não foi encontrado.");
                            return false;
                        }
                        //Restaurando os dados
                        SetHist("Restaurando dados(9.5)...");
                        ProcessStartInfo psData = new ProcessStartInfo();
                        psData.FileName = SourcePath + "\\bin\\pg_restore.exe";
                        psData.RedirectStandardOutput = false;
                        psData.Arguments = "-a --disable-triggers -p 5433 -U postgres -d docwin " + "\"" + dir + "data.dmp" + "\"";
                        psData.UseShellExecute = false;
                        psData.CreateNoWindow = true;
                        psData.RedirectStandardError = true;
                        Process proRESTData = Process.Start(psData);
                        proRESTData.WaitForExit();

                        if (proRESTData.ExitCode != 0)
                            SetHist(proRESTData.StandardError.ReadToEnd());

                        //Limpando informações de backup
                        ProcessStartInfo psBackup = new ProcessStartInfo();
                        psBackup.FileName = SourcePath + "\\bin\\psql.exe";
                        psBackup.RedirectStandardOutput = true;
                        psBackup.Arguments = $"-U postgres -d docwin -c \"ALTER DATABASE docwin SET search_path = docwin; UPDATE docwin.aux_preferencias_tb SET valor=NULL WHERE nome='lastbkpBD';\"";
                        psBackup.UseShellExecute = false;
                        psBackup.CreateNoWindow = false;
                        psBackup.RedirectStandardError = true;
                        Process proRESTUBKP = Process.Start(psBackup);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show("O seguinte erro aconteceu durante a restauração dos banco de dados:\r\n" + ex.Message, "Restauração cópia de segurança", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
            finally
            {
                Environment.SetEnvironmentVariable("PGPASSWORD", string.Empty);
            }
            return true;
        }

        public bool AbreInfo()
        {
            if (!File.Exists(OdlPath + "\\backup\\INFO.001"))
            {
                SetHist($"o arquivo {OdlPath + "\\backup\\INFO.001"} não foi encontrado.");
                return false;
            }

            string info = File.ReadAllText(OdlPath + "\\backup\\INFO.001");

            if (info.Length <= 2)
            {
                return false;
            }

            int c1 = ((int)info[0]) - 47;
            int c2 = ((int)info[1]) - 47;

            int lenghtPass = int.Parse(((char)c1).ToString() + ((char)c2).ToString());

            string Pass = string.Empty;

            if (info.Length <= 2 + (lenghtPass * 2))
            {
                return false;
            }
            else
            {
                int i = 2;
                while (i < 2 + (lenghtPass * 2))
                {
                    int tmpOf = ((int)info[i] - 50);
                    int tmpls = ((int)info[i + 1]) - tmpOf;

                    Pass += ((char)(tmpls)).ToString();
                    i += 2;
                }
            }

            password = Pass;

            return true;

        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
        }

        private void pgrTotal_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {

        }

        private void Grid_Initialized(object sender, EventArgs e)
        {
            txtSource83.Text = OdlPath;
            txtSource95.Text = SourcePath;
        }

        private void btnAlteraBD83_Click(object sender, RoutedEventArgs e)
        {
            FolderBrowserDialog fbd = new FolderBrowserDialog();
            fbd.Description = "Selecione a pasta de instalação do banco de dados do DOC 2013.";
            fbd.RootFolder = Environment.SpecialFolder.MyComputer;
            if (fbd.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                OdlPath = txtSource83.Text = fbd.SelectedPath;
                SourcePath = txtSource95.Text = fbd.SelectedPath + "9.5";
            }
        }

        private void btnAlteraBD95_Click(object sender, RoutedEventArgs e)
        {
            FolderBrowserDialog fbd = new FolderBrowserDialog();
            fbd.Description = "Selecione a pasta onde será realizada a instalação do banco de dados do DOC 2017.";
            fbd.RootFolder = Environment.SpecialFolder.MyComputer;
            if (fbd.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                SourcePath = txtSource95.Text = fbd.SelectedPath;
        }
    }
}
