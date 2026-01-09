import '../calculators/liquidacion_models.dart';
import '../calculators/salario_models.dart'; // Needed for WorkerProfile
import 'package:intl/intl.dart';

class CartaGenerator {
  static String generateLetter(LiquidacionInputModel? input, LiquidacionResultModel? result) {
    if (input == null || result == null) return "Error: Faltan datos para generar la carta.";

    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.simpleCurrency();

    String fecha = dateFormat.format(DateTime.now());
    String fechaSalida = dateFormat.format(input.endDate);

    // LOGIC: Who is the sender?
    bool isCompanySender = false;
    
    if (input.terminationType == TerminationType.despidoJustificado || 
        input.terminationType == TerminationType.despidoInjustificado) {
      isCompanySender = true;
    } else if (input.terminationType == TerminationType.mutuoAcuerdo) {
      if (input.mutualProposer == MutualAgreementProposer.empresa) {
        isCompanySender = true;
      }
    }

    String remitenteName;
    String destinatarioName;
    String cargoFirmante = "";

    if (isCompanySender) {
      // Sender: Company
      remitenteName = input.companyName.isNotEmpty ? input.companyName.toUpperCase() : "LA EMPRESA";
      destinatarioName = input.workerName.isNotEmpty ? input.workerName.toUpperCase() : "EL TRABAJADOR";
      cargoFirmante = "REPRESENTANTE LEGAL"; // Or input.companyRep
      if (input.companyRep.isNotEmpty) {
        cargoFirmante = "${input.companyRep}\n$cargoFirmante";
      }
    } else {
      // Sender: Employee
      remitenteName = input.workerName.isNotEmpty ? input.workerName.toUpperCase() : "EL TRABAJADOR";
      destinatarioName = input.companyName.isNotEmpty ? input.companyName.toUpperCase() : "LA EMPRESA";
      cargoFirmante = "TRABAJADOR";
    }

    StringBuffer buffer = StringBuffer();

    // 1. Header (Place & Date)
    buffer.writeln("Ciudad de Panamá, $fecha");
    buffer.writeln("");

    // Optional Company Header
    if (input.includeCompanyHeader && isCompanySender) {
      buffer.writeln("========================================");
      if (input.companyLogoPath != null && input.companyLogoPath!.isNotEmpty) {
         buffer.writeln("[LOGO: ${input.companyLogoPath}]");
      }
      buffer.writeln("${input.companyName.toUpperCase()}");
      buffer.writeln("RUC: ${input.companyRuc}  |  Tel: ${input.companyPhone}");
      buffer.writeln("${input.companyAddress}");
      buffer.writeln("========================================");
      buffer.writeln("");
    }

    // 2. Addressee
    buffer.writeln("Señor(a):");
    buffer.writeln(destinatarioName);
    buffer.writeln("E. S. D.");
    buffer.writeln("");

    // 3. Body
    if (isCompanySender) {
       // EMPRESA -> EMPLEADO
       buffer.writeln("Estimado(a) Sr(a). ${input.workerName}:");
       buffer.writeln("");
       
       if (input.terminationType == TerminationType.despidoJustificado) {
         buffer.writeln("Por medio de la presente le comunicamos la decisión de la empresa de dar por terminada la relación laboral de trabajo, por CAUSA JUSTIFICADA, efectiva a partir del día $fechaSalida.");
       } else if (input.terminationType == TerminationType.despidoInjustificado) {
         buffer.writeln("Por medio de la presente le comunicamos la decisión de la empresa de dar por terminada la relación laboral (Despido Injustificado), efectiva a partir del día $fechaSalida.");
         buffer.writeln("Reconocemos el pago de su indemnización y derechos adquiridos conforme a la ley.");
       } else if (input.terminationType == TerminationType.mutuoAcuerdo) {
         buffer.writeln("Sirva la presente para formalizar la terminación de la relación laboral por MUTUO ACUERDO, según lo conversado, efectiva a partir del día $fechaSalida.");
       } else {
         buffer.writeln("Le comunicamos la terminación de su contrato laboral efectiva el $fechaSalida.");
       }
       
       buffer.writeln("");
       buffer.writeln("Agradecemos el tiempo de servicio prestado a nuestra organización.");
       buffer.writeln("Adjunto a la presente encontrará el desglose de su LIQUIDACIÓN FINAL y el pago de sus prestaciones laborales.");
       
    } else {
       // EMPLEADO -> EMPRESA
       buffer.writeln("Estimados señores:");
       buffer.writeln("");
       
       if (input.terminationType == TerminationType.renunciaVoluntaria) {
         buffer.writeln("Por medio de la presente, yo, ${input.workerName.toUpperCase()}, con cédula de identidad personal N° ${input.workerId}, comunico mi decisión de apresentar mi RENUNCIA IRREVOCABLE al cargo de ${input.position ?? "colaborador"} que ocupo en su empresa.");
         buffer.writeln("");
         buffer.writeln("Esta renuncia será efectiva a partir del día $fechaSalida.");
         buffer.writeln("");
         buffer.writeln("Agradezco la oportunidad brindada durante mi tiempo de servicio.");
       } else if (input.terminationType == TerminationType.mutuoAcuerdo) {
         buffer.writeln("Por medio de la presente manifiesto mi voluntad de terminar la relación de trabajo por MUTUO ACUERDO, con efectividad a partir del $fechaSalida.");
       } else {
         buffer.writeln("Por este medio informo la terminación de mi relación laboral el día $fechaSalida.");
       }
       
       buffer.writeln("");
       buffer.writeln("Solicito gestionar el pago de mis derechos adquiridos y prestaciones laborales correspondientes conforme a la ley.");
    }
    
    buffer.writeln("");
    
    // 4. Financial Summary (Simplified for Letter)
    buffer.writeln("RESUMEN DE PAGO (Estimado):");
    buffer.writeln("------------------------------------------------");
    buffer.writeln("Total Devengado:    ${currencyFormat.format(result.subtotalDevengos)}");
    buffer.writeln("(-) Deducciones:    ${currencyFormat.format(result.totalDeducciones)}");
    buffer.writeln("TOTAL NETO A RECIBIR: ${currencyFormat.format(result.netoPagar)}");
    buffer.writeln("------------------------------------------------");
    buffer.writeln("");

    // 5. Signature
    buffer.writeln("Atentamente,");
    buffer.writeln("");
    buffer.writeln("");
    buffer.writeln("__________________________");
    if (isCompanySender) {
      buffer.writeln(input.companyName.toUpperCase());
      buffer.writeln(cargoFirmante); 
    } else {
      buffer.writeln(input.workerName.toUpperCase());
      buffer.writeln("Cédula: ${input.workerId}");
    }

    return buffer.toString();
  }

  static String generateReceipt(LiquidacionInputModel? input, LiquidacionResultModel? result) {
    if (input == null || result == null) return "Error: Faltan datos.";
    
    final currencyFormat = NumberFormat.simpleCurrency();
    StringBuffer buffer = StringBuffer();
    
    String tipoTerminacionDesc = input.terminationType.toString().split('.').last.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}').toUpperCase().trim();
    String antiguedadTexto = "${result.yearsWorked} años, ${result.monthsWorked} meses, ${result.daysWorked} días";

    // 1) ENCABEZADO PRINCIPAL (Vertical Layout)
    if (input.includeCompanyHeader) {
      if (input.companyName.isNotEmpty) buffer.writeln(input.companyName.toUpperCase());
      if (input.companyRuc.isNotEmpty) buffer.writeln("RUC: ${input.companyRuc}");
      if (input.companyAddress.isNotEmpty) buffer.writeln("Dirección: ${input.companyAddress}");
      buffer.writeln("");
    }
    buffer.writeln("COMPROBANTE DE PAGO DE LIQUIDACIÓN");
    buffer.writeln("Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}");
    buffer.writeln("============================================================");

    // 2) DATOS BASE
    buffer.writeln("TRABAJADOR: ${input.workerName.toUpperCase()}");
    buffer.writeln("CÉDULA:     ${input.workerId}");
    buffer.writeln("CARGO:      ${input.position ?? 'N/A'}");
    buffer.writeln("ANTIGÜEDAD: $antiguedadTexto");
    buffer.writeln("CAUSA:      $tipoTerminacionDesc");
    buffer.writeln("SALARIO:    ${currencyFormat.format(input.salary)}");
    buffer.writeln("============================================================");
    buffer.writeln("");

    // 3) DETALLE DE PAGOS (DEVENGOS)
    buffer.writeln("I. DEVENGOS (PAGOS BRUTOS)");
    buffer.writeln("------------------------------------------------------------");
    buffer.writeln(padColumns("CONCEPTO", "MONTO", 45));
    buffer.writeln("------------------------------------------------------------");
    
    if (result.salarioAdeudado > 0)
      buffer.writeln(padColumns("Salario Pendiente", currencyFormat.format(result.salarioAdeudado), 45));
    if (result.vacacionesVencidas > 0)
      buffer.writeln(padColumns("Vacaciones Vencidas", currencyFormat.format(result.vacacionesVencidas), 45));
    if (result.vacacionesProporcionales > 0)
      buffer.writeln(padColumns("Vacaciones Proporcionales", currencyFormat.format(result.vacacionesProporcionales), 45));
    if (result.decimoProporcional > 0)
      buffer.writeln(padColumns("XIII Mes Proporcional", currencyFormat.format(result.decimoProporcional), 45));
    if (result.primaAntiguedad > 0)
      buffer.writeln(padColumns("Prima de Antigüedad", currencyFormat.format(result.primaAntiguedad), 45));
    if (result.indemnizacion > 0)
      buffer.writeln(padColumns("Indemnización Legal", currencyFormat.format(result.indemnizacion), 45));
    if (result.preaviso > 0)
      buffer.writeln(padColumns("Preaviso", currencyFormat.format(result.preaviso), 45));

    double extras = input.overtimeAmount + input.unpaidHolidaysAmount + input.pendingBonuses + input.otherSums;
    if (extras > 0) 
       buffer.writeln(padColumns("Otros Ingresos Laborales", currencyFormat.format(extras), 45));

    buffer.writeln("------------------------------------------------------------");
    buffer.writeln(padColumns("SUBTOTAL DEVENGOS", currencyFormat.format(result.subtotalDevengos), 45));
    buffer.writeln("");

    // 4) DETALLE DE DEDUCCIONES
    buffer.writeln("II. DEDUCCIONES");
    buffer.writeln("------------------------------------------------------------");
    
    // CSS
    if ((result.cssSalario ?? 0) > 0)
       buffer.writeln(padColumns("Seguro Social (S/Salario)", currencyFormat.format(result.cssSalario), 45));
    if ((result.cssVacaciones ?? 0) > 0)
       buffer.writeln(padColumns("Seguro Social (S/Vacaciones)", currencyFormat.format(result.cssVacaciones), 45));
    if ((result.cssDecimo ?? 0) > 0)
       buffer.writeln(padColumns("Seguro Social (S/XIII Mes)", currencyFormat.format(result.cssDecimo), 45));
    if ((result.cssPreaviso ?? 0) > 0)
       buffer.writeln(padColumns("Seguro Social (S/Preaviso)", currencyFormat.format(result.cssPreaviso), 45));
       
    // SE
    if ((result.seSalario ?? 0) > 0)
       buffer.writeln(padColumns("Seguro Educativo (S/Salario)", currencyFormat.format(result.seSalario), 45));
    if ((result.seVacaciones ?? 0) > 0)
       buffer.writeln(padColumns("Seguro Educativo (S/Vacaciones)", currencyFormat.format(result.seVacaciones), 45));
    if ((result.sePreaviso ?? 0) > 0)
       buffer.writeln(padColumns("Seguro Educativo (S/Preaviso)", currencyFormat.format(result.sePreaviso), 45));
       
    // ISR
    if (result.isr > 0)
       buffer.writeln(padColumns("Impuesto Sobre la Renta", currencyFormat.format(result.isr), 45));
    
    // Others
    if (input.loans > 0)
       buffer.writeln(padColumns("Préstamos Personales", currencyFormat.format(input.loans), 45));
    if (input.advances > 0)
       buffer.writeln(padColumns("Adelantos de Salario", currencyFormat.format(input.advances), 45));
    
    double otrosMisc = input.otherDeductions + input.otherDeductionAmount;
    if (otrosMisc > 0) {
       String name = input.otherDeductionName.isNotEmpty ? input.otherDeductionName : "Otras Deducciones";
       // Ensure name isn't too long
       if (name.length > 30) name = name.substring(0, 27) + "...";
       buffer.writeln(padColumns(name, currencyFormat.format(otrosMisc), 45));
    }

    buffer.writeln("------------------------------------------------------------");
    buffer.writeln(padColumns("TOTAL DEDUCCIONES", currencyFormat.format(result.totalDeducciones), 45));
    buffer.writeln("");

    // Rubros Exentos Note
    if (result.primaAntiguedad > 0 || result.indemnizacion > 0) {
       buffer.writeln("NOTA: Rubros exentos de deducciones de ley:");
       if (result.primaAntiguedad > 0) buffer.writeln(" - Prima de Antigüedad");
       if (result.indemnizacion > 0) buffer.writeln(" - Indemnización Art. 225");
       buffer.writeln("");
    }

    buffer.writeln("------------------------------------------------------------");
    buffer.writeln(padColumns("TOTAL DEDUCCIONES", currencyFormat.format(result.totalDeducciones), 45));
    buffer.writeln("");

    // 5) NETO
    buffer.writeln("************************************************************");
    buffer.writeln(padColumns("TOTAL NETO A PAGAR", currencyFormat.format(result.totalPagar), 45));
    buffer.writeln("************************************************************");
    buffer.writeln("");
    
    buffer.writeln("Recibí conforme:");
    buffer.writeln("");
    buffer.writeln("");
    buffer.writeln("__________________________");
    buffer.writeln("Firma del Trabajador");
    buffer.writeln("Cédula: ${input.workerId}");
    buffer.writeln("");
    // Add date line at bottom too
    buffer.writeln("Fecha: ____/____/_______");

    return buffer.toString();
  }

  // Helper for simple text column alignment
  static String padColumns(String left, String right, int width) {
    if (left.length > width) {
        String truncated = left.substring(0, width - 3) + "...";
        int spaces = width - truncated.length;
        if (spaces < 1) spaces = 1;
        return truncated + (" " * spaces) + right;
    }
    int spaces = width - left.length;
    if (spaces < 1) spaces = 1;
    return left + (" " * spaces) + right;
  }

  // --- NEW GENERATORS ---

  static String generateContract(WorkerProfile worker) {
    if (worker.name.isEmpty) return "Error: El trabajador no tiene nombre registrado.";
    
    final fmt = DateFormat('dd/MM/yyyy');
    String fecha = fmt.format(DateTime.now());
    String cedula = worker.cedula ?? '';
    String inicioLaboral = worker.startDate != null ? fmt.format(worker.startDate!) : '__________';
    
    StringBuffer b = StringBuffer();
    b.writeln("CONTRATO INDIVIDUAL DE TRABAJO");
    b.writeln("");
    b.writeln("Panamá, $fecha");
    b.writeln("");
    b.writeln("ENTRE:");
    b.writeln("LA EMPRESA (EL EMPLEADOR), y");
    b.writeln("${worker.name.toUpperCase()} (EL TRABAJADOR), con cédula ${cedula.isNotEmpty ? cedula : '_______'}.");
    b.writeln("");
    b.writeln("CLÁUSULAS:");
    b.writeln("PRIMERO: El Trabajador prestará servicios como ${worker.position.isNotEmpty ? worker.position.toUpperCase() : '__________'}.");
    b.writeln("");
    b.writeln("SEGUNDO: El salario convenido es de B/. ${worker.basePayment.toStringAsFixed(2)} pagadero en forma ${worker.paymentMode.toString().split('.').last.toUpperCase()}.");
    b.writeln("");
    b.writeln("TERCERO: La jornada de trabajo será de _______ horas semanales.");
    b.writeln("");
    b.writeln("CUARTO: El contrato inicia el $inicioLaboral y es de tipo ${worker.contractType.toString().split('.').last.toUpperCase()}.");
    b.writeln("");
    b.writeln("(Espacio para más cláusulas personalizadas)");
    b.writeln("");
    b.writeln("");
    b.writeln("__________________________          __________________________");
    b.writeln("      EL EMPLEADOR                        EL TRABAJADOR");
    b.writeln("                                  Cédula: $cedula");
    return b.toString();
  }

  static String generateWarning(WorkerProfile worker) {
    if (worker.name.isEmpty) return "Error: El trabajador no tiene nombre.";
    
    final fmt = DateFormat('dd/MM/yyyy');
    String fecha = fmt.format(DateTime.now());
    
    StringBuffer b = StringBuffer();
    b.writeln("AMONESTACIÓN ESCRITA");
    b.writeln("");
    b.writeln("Fecha: $fecha");
    b.writeln("Para: ${worker.name.toUpperCase()}");
    b.writeln("Cargo: ${worker.position}");
    b.writeln("");
    b.writeln("Asunto: Amonestación por falta laboral");
    b.writeln("");
    b.writeln("Estimado(a) colaborador(a):");
    b.writeln("");
    b.writeln("Por medio de la presente se le hace un llamado de atención formal debido a:");
    b.writeln("[DESCRIBIR AQUÍ LA FALTA COMETIDA]");
    b.writeln("");
    b.writeln("Hechos ocurridos el día: _________________");
    b.writeln("");
    b.writeln("Esta acción contraviene las normas establecidas en nuestro Reglamento Interno y el Código de Trabajo.");
    b.writeln("Le exhortamos a corregir esta conducta para evitar medidas disciplinarias más severas.");
    b.writeln("");
    b.writeln("");
    b.writeln("ATENTAMENTE,");
    b.writeln("");
    b.writeln("__________________________");
    b.writeln("LA EMPRESA");
    b.writeln("");
    b.writeln("");
    b.writeln("Recibido por:");
    b.writeln("__________________________");
    b.writeln("${worker.name.toUpperCase()}");
    b.writeln("Fecha: ______________");
    
    return b.toString();
  }

  static String generateVacationRequest(WorkerProfile worker, DateTime start, DateTime end, {int? days}) {
    final fmt = DateFormat('dd/MM/yyyy');
    final duration = days ?? (end.difference(start).inDays + 1);
    
    StringBuffer b = StringBuffer();
    b.writeln("SOLICITUD DE VACACIONES");
    b.writeln("");
    b.writeln("Fecha: ${fmt.format(DateTime.now())}");
    b.writeln("");
    b.writeln("Señores:");
    b.writeln("DEPARTAMENTO DE RECURSOS HUMANOS");
    b.writeln("E. S. D.");
    b.writeln("");
    b.writeln("Yo, ${worker.name.toUpperCase()}, con cédula de identidad personal N° ${worker.cedula ?? '_______'}, por este medio solicito mi periodo de vacaciones reglamentarias acumuladas.");
    b.writeln("");
    b.writeln("El periodo solicitado comprende:");
    b.writeln("- Desde el: ${fmt.format(start)}");
    b.writeln("- Hasta el: ${fmt.format(end)}");
    b.writeln("- Reincorporación: ${fmt.format(end.add(const Duration(days: 1)))}");
    b.writeln("- Total de días: $duration");
    b.writeln("");
    b.writeln("Agradezco de antemano su gestión para procesar esta solicitud conforme a las leyes laborales vigentes.");
    b.writeln("");
    b.writeln("Atentamente,");
    b.writeln("");
    b.writeln("");
    b.writeln("__________________________");
    b.writeln("${worker.name.toUpperCase()}");
    b.writeln("");
    b.writeln("");
    b.writeln("__________________________");
    b.writeln("APROBADO POR (Empresa)");
    
    return b.toString();
  }

  static String generatePermissionRequest(WorkerProfile worker, DateTime date, String type, String reason) {
    final fmt = DateFormat('dd/MM/yyyy');
    
    StringBuffer b = StringBuffer();
    b.writeln("SOLICITUD DE PERMISO / LICENCIA");
    b.writeln("");
    b.writeln("Fecha: ${fmt.format(DateTime.now())}");
    b.writeln("");
    b.writeln("Yo, ${worker.name.toUpperCase()}, solicito formalmente un permiso para ausentarme de mis labores el día ${fmt.format(date)} por el siguiente motivo:");
    b.writeln("");
    b.writeln("TIPO: ${type.toUpperCase()}");
    b.writeln("MOTIVO: $reason");
    b.writeln("");
    b.writeln("Me comprometo a presentar los justificantes correspondientes de ser necesario.");
    b.writeln("");
    b.writeln("Atentamente,");
    b.writeln("");
    b.writeln("");
    b.writeln("__________________________");
    b.writeln("${worker.name.toUpperCase()}");
    b.writeln("");
    b.writeln("");
    b.writeln("__________________________");
    b.writeln("NOTIFICADO / APROBADO");
    
    return b.toString();
  }
}
