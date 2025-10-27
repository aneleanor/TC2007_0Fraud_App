//
//  TermsView.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 12/10/25.
//

import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                section("""
                1. Aceptación  
                Al utilizar la aplicación 0-Fraud, aceptas estos Términos y Condiciones. Si no estás de acuerdo con alguna parte, por favor no utilices la app.
                """)

                section("""
                2. Uso de la aplicación  
                La app permite reportar incidentes o intentos de fraude. Te comprometes a proporcionar información veraz y a no realizar reportes malintencionados.
                """)

                section("""
                3. Privacidad y datos  
                Podemos recolectar y procesar datos que proporcionas (como correo e información de reportes) para operar y mejorar el servicio. Consulta el Aviso de Privacidad para conocer más sobre el tratamiento de tus datos.
                """)

                section("""
                4. Contenido prohibido  
                No se permite publicar contenido ilegal, difamatorio, discriminatorio, pornográfico, de incitación al odio o que infrinja derechos de terceros.
                """)

                section("""
                5. Responsabilidad  
                La app se ofrece “tal cual”. No garantizamos la detección o eliminación de todo contenido fraudulento ni la disponibilidad continua del servicio.
                """)

                section("""
                6. Cambios  
                Podemos actualizar estos Términos. El uso continuado de la app después de los cambios implica la aceptación de los mismos.
                """)

            }
            .padding(20)
        }
        .navigationTitle("Términos y Condiciones")
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
    NavigationStack { TermsView() }
}

