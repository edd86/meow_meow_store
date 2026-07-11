enum TransactionCategory {
  materialLimpieza('Material de limpieza'),
  suministros('Suministros de oficina'),
  servicios('Servicios (luz, agua, internet)'),
  alquiler('Alquiler / Renta'),
  proveedor('Proveedor de productos'),
  transporte('Transporte / Envíos'),
  mantenimiento('Mantenimiento'),
  salario('Salario / Personal'),
  impuestos('Impuestos / Taxes'),
  otro('Otro');

  final String label;
  const TransactionCategory(this.label);
}
