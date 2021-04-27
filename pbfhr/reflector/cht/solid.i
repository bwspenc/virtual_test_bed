core_heat_flux = 5e3

[Mesh]
  type = FileMesh
  file = solid.e
[]

[Variables]
  [T]
  []
[]

[AuxVariables]
  [flux]
    family = MONOMIAL
    order = CONSTANT
  []
  [nek_temp]
  []
[]

[Functions]
  [nek_temp_ic]
    type = ParsedFunction
    value = 923.0-50.0*(r-3.348)
    vars = 'r'
    vals = 'r'
  []
  [r]
    type = ParsedFunction
    value = sqrt(x*x+y*y)
  []
[]

[ICs]
  [nek_temp]
    type = FunctionIC
    variable = nek_temp
    function = nek_temp_ic
  []
[]

[Kernels]
  [conduction]
    type = HeatConduction
    variable = T
  []
[]

[AuxKernels]
  [flux]
    type = NormalDiffusionFluxAux
    variable = flux
    coupled = T
    diffusivity = thermal_conductivity
    boundary = 'fluid_solid_interface'
  []
[]

[BCs]
  [cht_interface]
    type = MatchedValueBC
    variable = T
    v = nek_temp
    boundary = 'fluid_solid_interface'
  []
  [symmetry]
    type = NeumannBC
    variable = T
    boundary = 'symmetry'
    value = 0.0
  []
  [top_and_bottom]
    type = NeumannBC
    variable = T
    boundary = 'top bottom'
  []
  [inner_surface]
    type = NeumannBC
    variable = T
    value = ${core_heat_flux}
    boundary = 'inner_surface'
  []
  [outer_surface]
    type = ConvectiveHeatFluxBC
    variable = T
    T_infinity = 'Tinf'
    heat_transfer_coefficient = 'htc'
    boundary = 'barrel_surface'
  []
[]

[ThermalContact]
  [one_to_two]
    type = GapHeatTransfer
    variable = T
    primary = one_to_two
    secondary = two_to_one
    quadrature = true
    emissivity_primary = 0.8
    emissivity_secondary = 0.8
  []
  [two_to_three]
    type = GapHeatTransfer
    variable = T
    primary = two_to_three
    secondary = three_to_two
    quadrature = true
    emissivity_primary = 0.8
    emissivity_secondary = 0.8
  []
[]

[Materials]
  [k_graphite]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity'
    prop_values = '43.73' # evaluated at 650 C
    block = '2 3'
  []
  [k_steel]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity'
    prop_values = '23.82' # evaluated at 650 C
    block = '1'
  []
  [htc_and_Tinf]
    type = GenericConstantMaterial
    prop_names = 'htc Tinf'
    prop_values = '10.0 300.0'
  []
[]

[MultiApps]
  [nek]
    type = TransientMultiApp
    app_type = NekApp
    input_files = 'nek.i'
    sub_cycling = true
    execute_on = timestep_end
  []
[]

[Transfers]
  [temperature]
    type = MultiAppNearestNodeTransfer
    source_variable = temp
    direction = from_multiapp
    multi_app = nek
    variable = nek_temp
    fixed_meshes = true
  []
  [flux]
    type = MultiAppNearestNodeTransfer
    source_variable = flux
    direction = to_multiapp
    multi_app = nek
    variable = avg_flux
    fixed_meshes = true
    source_boundary = 'fluid_solid_interface'
  []
  [flux_integral]
    type = MultiAppPostprocessorTransfer
    to_postprocessor = flux_integral
    direction = to_multiapp
    from_postprocessor = flux_integral
    multi_app = nek
  []
  [max_T]
    type = MultiAppPostprocessorTransfer
    to_postprocessor = impose_max_T
    direction = to_multiapp
    from_postprocessor = max_T
    multi_app = nek
  []
  [min_T]
    type = MultiAppPostprocessorTransfer
    to_postprocessor = impose_min_T
    direction = to_multiapp
    from_postprocessor = min_T_barrel_surface
    multi_app = nek
  []
  [synchronization_in]
    type = MultiAppPostprocessorTransfer
    to_postprocessor = synchronization_in
    direction = to_multiapp
    from_postprocessor = synchronization_in
    multi_app = nek
  []
[]

[Postprocessors]
  [flux_integral]
    type = SideIntegralVariablePostprocessor
    variable = flux
    boundary = 'fluid_solid_interface'
  []
  [area_facing_pebbles]
    type = AreaPostprocessor
    boundary = 'inner_surface'
    execute_on = 'initial'
  []
  [heat_loss_from_barrel]
    type = SideFluxIntegral
    diffusivity = 'thermal_conductivity'
    variable = T
    boundary = 'barrel_surface'
  []
  [heat_gain_from_pebbles]
    type = SideFluxIntegral
    diffusivity = 'thermal_conductivity'
    variable = T
    boundary = 'inner_surface'
  []
  [max_T]
    type = NodalExtremeValue
    variable = T
    value_type = max
  []
  [min_T_barrel_surface]
    type = NodalExtremeValue
    variable = T
    value_type = min
    boundary = 'barrel_surface'
  []
  [synchronization_in]
    type = Receiver
    default = 1
  []
[]

[Executioner]
  type = Transient
  dt = 0.002
  nl_abs_tol = 1e-8
  num_steps = 1000
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
  hide = 'synchronization_in'
[]