//
//  PrivacyView.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

    
                section("""
                Última actualización: 13 de octubre de 2025

                En 0-Fraud valoramos tu confianza y estamos comprometidos con la protección de tu información personal. Este Aviso de Privacidad explica de forma general cómo recopilamos, utilizamos y protegemos los datos que proporcionas al utilizar nuestra aplicación.
                """)

                section("""
                1. Responsable del tratamiento
                0-Fraud es responsable del uso y protección de tus datos personales. 
                """)

                section("""
                2. Datos personales que recabamos
                • Nombre y apellido  
                • Correo electrónico  
                • Contraseña (almacenada de forma cifrada)  
                • Información incluida en tus reportes (por ejemplo, URL, descripción y evidencia)
                """)

                section("""
                3. Finalidades del tratamiento
                • Crear y administrar tu cuenta de usuario  
                • Procesar y almacenar reportes enviados por la comunidad  
                • Mostrar estadísticas y métricas generales  
                • Mejorar el funcionamiento y seguridad de la app  
                • Enviar comunicaciones operativas relacionadas con tu cuenta
                """)

                section("""
                4. Protección de la información
                Tus datos se almacenan en servidores seguros y se manejan con medidas razonables para evitar accesos no autorizados, pérdida o alteración.  
                0-Fraud no vende ni renta tus datos a terceros. Solo los compartiremos si lo requiere la ley o una autoridad competente.
                """)

                section("""
                5. Derechos ARCO
                Puedes acceder, rectificar, cancelar u oponerte al uso de tus datos. Si no estas acuerdo con la manera en que manejamos la información te invitamos a eliminar tu cuenta y dejar de usar la app. 
                """)

                section("""
                6. Cambios al aviso
                Podemos actualizar este aviso por mejoras o cambios normativos. Publicaremos cualquier modificación en la sección  de Aviso de Privacidad dentro de la app.
                """)

                section("""
                7. Aceptación
                Al utilizar 0-Fraud, confirmas que leíste y comprendiste este Aviso y otorgas tu consentimiento para el tratamiento de tus datos conforme a lo aquí descrito.
                """)
            }
            .padding(20)
        }
        .navigationTitle("Aviso de Privacidad")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Regresar") {
                    dismiss()
                }
                .bold()
            }
        }
    }

    private func section(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .textSelection(.enabled)
    }
}

#Preview {
    NavigationStack { PrivacyView() }
}
