﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace AssistenteMigracao.Properties {
    using System;
    
    
    /// <summary>
    ///   A strongly-typed resource class, for looking up localized strings, etc.
    /// </summary>
    // This class was auto-generated by the StronglyTypedResourceBuilder
    // class via a tool like ResGen or Visual Studio.
    // To add or remove a member, edit your .ResX file then rerun ResGen
    // with the /str option, or rebuild your VS project.
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Resources.Tools.StronglyTypedResourceBuilder", "4.0.0.0")]
    [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    internal class Resources {
        
        private static global::System.Resources.ResourceManager resourceMan;
        
        private static global::System.Globalization.CultureInfo resourceCulture;
        
        [global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
        internal Resources() {
        }
        
        /// <summary>
        ///   Returns the cached ResourceManager instance used by this class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Resources.ResourceManager ResourceManager {
            get {
                if (object.ReferenceEquals(resourceMan, null)) {
                    global::System.Resources.ResourceManager temp = new global::System.Resources.ResourceManager("AssistenteMigracao.Properties.Resources", typeof(Resources).Assembly);
                    resourceMan = temp;
                }
                return resourceMan;
            }
        }
        
        /// <summary>
        ///   Overrides the current thread's CurrentUICulture property for all
        ///   resource lookups using this strongly typed resource class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Globalization.CultureInfo Culture {
            get {
                return resourceCulture;
            }
            set {
                resourceCulture = value;
            }
        }
        
        /// <summary>
        ///   Looks up a localized resource of type System.Drawing.Bitmap.
        /// </summary>
        internal static System.Drawing.Bitmap shuffle {
            get {
                object obj = ResourceManager.GetObject("shuffle", resourceCulture);
                return ((System.Drawing.Bitmap)(obj));
            }
        }
        
        /// <summary>
        ///   Looks up a localized resource of type System.Drawing.Icon similar to (Icon).
        /// </summary>
        internal static System.Drawing.Icon tree_structure_Windows_32x32 {
            get {
                object obj = ResourceManager.GetObject("tree_structure_Windows_32x32", resourceCulture);
                return ((System.Drawing.Icon)(obj));
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to UPDATE docwin.aux_preferencias_tb SET valor=&apos;0.4&apos; WHERE nome=&apos;inf_bd_rel&apos;;
        /// UPDATE docwin.aux_preferencias_tb SET valor=&apos;2017&apos; WHERE nome=&apos;inf_bd_ver&apos;;
        /// 
        /// SET client_min_messages TO ERROR;
        /// 
        /// SELECT docwin.inserealterahelp(&apos;A&apos;,&apos;C&apos;,&apos;ACDLGSLDC&apos;,&apos;
        ///   Determina   se  será ou não exibido o
        ///   diálogo:  &lt;b&gt;&quot;Selecionar  os  documentos 
        ///   que serão impressos automaticamente?&quot;&lt;/b&gt;
        /// 
        ///   Caso  não  marcado será considerada a 
        ///   resposta &lt;b&gt;NÃO&lt;/b&gt; para o diálogo acima.&apos;,&apos;Seleção de documentos&apos;);
        /// 
        /// CREA [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string UPDATE_2017 {
            get {
                return ResourceManager.GetString("UPDATE_2017", resourceCulture);
            }
        }
    }
}
