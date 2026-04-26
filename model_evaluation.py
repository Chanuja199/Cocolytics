import sys
import numpy as np
import tensorflow as tf
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
import cv2
import os

def evaluate_model(tflite_model_path, test_directory_path):
    # Load the TFLite model and allocate tensors.
    interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
    interpreter.allocate_tensors()

    # Get input and output tensors.
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    # Expected categories (assuming alphabetical order like Keras flow_from_directory)
    categories = ['Bud Rot', 'Healthy', 'Leaf Spot', 'Lethal Yellowing', 'Root Wilt']
    
    y_true = []
    y_pred = []
    
    # Loop over categories and their respective image folders
    for label_idx, category in enumerate(categories):
        folder_path = os.path.join(test_directory_path, category)
        if not os.path.exists(folder_path):
            print(f"Warning: Folder {folder_path} does not exist. Skipping.")
            continue
            
        for img_name in os.listdir(folder_path):
            img_path = os.path.join(folder_path, img_name)
            
            # Read and preprocess the image (assumes 224x224 RGB input)
            img = cv2.imread(img_path)
            if img is None: continue
            
            img = cv2.resize(img, (224, 224))
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            
            # Normalize depending on how the model was trained
            # Common normalization is standard scaling or 0-1
            input_data = np.expand_dims(img / 255.0, axis=0).astype(np.float32)
            
            # Perform inference
            interpreter.set_tensor(input_details[0]['index'], input_data)
            interpreter.invoke()
            output_data = interpreter.get_tensor(output_details[0]['index'])
            
            predicted_idx = np.argmax(output_data[0])
            
            y_true.append(label_idx)
            y_pred.append(predicted_idx)
            
    if len(y_true) == 0:
        print("No images found for evaluation.")
        return

    # Calculate metrics
    accuracy = accuracy_score(y_true, y_pred)
    precision = precision_score(y_true, y_pred, average='weighted', zero_division=0)
    recall = recall_score(y_true, y_pred, average='weighted', zero_division=0)
    f1 = f1_score(y_true, y_pred, average='weighted', zero_division=0)
    conf_matrix = confusion_matrix(y_true, y_pred)

    print("\n--- Model Evaluation Results ---")
    print(f"Accuracy:  {accuracy:.4f}")
    print(f"Precision: {precision:.4f}")
    print(f"Recall:    {recall:.4f}")
    print(f"F1-Score:  {f1:.4f}")
    print("\nConfusion Matrix:")
    print(conf_matrix)
    print("\nRows: True Labels, Columns: Predicted Labels")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python model_evaluation.py <path_to_tflite_model> <path_to_test_dataset>")
        sys.exit(1)
        
    model_path = sys.argv[1]
    dataset_path = sys.argv[2]
    evaluate_model(model_path, dataset_path)
