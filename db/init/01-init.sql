
-- Create medicines table
CREATE TABLE medicines (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    quantity INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create patients table
CREATE TABLE patients (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert some sample data
INSERT INTO medicines (name, description, quantity) VALUES
('Ibrutinib', 'For treating certain cancers, such as mantle cell lymphoma and chronic lymphocytic leukemia.', 100),
('Trastuzumab', 'For treating HER2-positive breast cancer.', 50),
('Letrozole', 'For treating breast cancer in postmenopausal women.', 200);

INSERT INTO patients (first_name, last_name, date_of_birth) VALUES
('John', 'Doe', '1975-04-12'),
('Jane', 'Smith', '1982-09-23');
