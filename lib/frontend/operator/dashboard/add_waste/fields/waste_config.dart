const wasteCategoryInfo = {
  'greens': 'Nitrogen source (fast decomposition)',
  'browns': 'Carbon source (slow decomposition)',
  'compost': 'Compost - General organic matter',
};

const plantTypeOptions = {
  'greens': [
    {'value': 'leafy_vegetables', 'label': 'Leafy Vegetables', 'needs': 'Needs nitrogen'},
    {'value': 'herbs', 'label': 'Herbs', 'needs': 'Needs nitrogen'},
  ],
  'browns': [
    {'value': 'fruiting_vegetables', 'label': 'Fruiting Vegetables', 'needs': 'Needs carbon'},
    {'value': 'fruit_trees', 'label': 'Fruit Trees', 'needs': 'Needs carbon'},
    {'value': 'root_crops', 'label': 'Root Crops', 'needs': 'Needs carbon'},
  ],
  'compost': [
    {'value': 'compost', 'label': 'Compost', 'needs': 'General purpose'},
  ],
};
