-- Update ranch_lots constraint to use Spanish value for 'cria' instead of 'breeding'
-- This allows the new breeding module to work with Spanish enum values

-- First, drop the existing constraint
ALTER TABLE ranch_lots DROP CONSTRAINT ranch_lots_lot_type_check;

-- Add the new constraint with Spanish values
ALTER TABLE ranch_lots ADD CONSTRAINT ranch_lots_lot_type_check 
  CHECK (lot_type IN ('cria', 'recria', 'engorde', 'reproductiva', 'general', 'breeding', 'rearing', 'fattening', 'reproductive'));

-- Update existing records from English to Spanish values
UPDATE ranch_lots SET lot_type = 'cria' WHERE lot_type = 'breeding';
UPDATE ranch_lots SET lot_type = 'recria' WHERE lot_type = 'rearing';
UPDATE ranch_lots SET lot_type = 'engorde' WHERE lot_type = 'fattening';
UPDATE ranch_lots SET lot_type = 'reproductiva' WHERE lot_type = 'reproductive';

-- Now drop and recreate with only Spanish values
ALTER TABLE ranch_lots DROP CONSTRAINT ranch_lots_lot_type_check;
ALTER TABLE ranch_lots ADD CONSTRAINT ranch_lots_lot_type_check 
  CHECK (lot_type IN ('cria', 'recria', 'engorde', 'reproductiva', 'general'));
