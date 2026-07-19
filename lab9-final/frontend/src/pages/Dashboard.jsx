import { useEffect, useState } from "react";
import api from "../services/api";

function Dashboard({ setToken }) {
  const [files, setFiles] = useState([]);
  const [fileName, setFileName] = useState("");
  const [category, setCategory] = useState("");
  const [size, setSize] = useState("");
  const [loading, setLoading] = useState(false);
  const currentUser = localStorage.getItem("user");

  useEffect(() => {
    loadFiles();
  }, []);

  async function loadFiles() {
    try {
      setLoading(true);
      const response = await api.get("/v1/files");
      setFiles(response.data);
      setLoading(false);
    } catch (error) {
      console.error(error);
      setLoading(false);
    }
  }

  async function createFile() {
    if (!fileName || !category || !size) {
      alert("Todos los campos son obligatorios");
      return;
    }
    try {
      await api.post("/v1/files", { fileName, category, size });
      setFileName("");
      setCategory("");
      setSize("");
      loadFiles();
    } catch (error) {
      console.error(error);
      alert("Error creando archivo");
    }
  }

  async function deleteFile(id) {
    try {
      await api.delete(`/v1/files/${id}`);
      loadFiles();
    } catch (error) {
      console.error(error);
      alert("Error eliminando archivo");
    }
  }

  function logout() {
    localStorage.clear();
    setToken(null);
  }

  const totalFiles = files.length;
  const totalPdf = files.filter((file) => file.category === "PDF").length;
  const totalImages = files.filter((file) => file.category === "Imagen").length;
  const totalSize = files.reduce((acc, file) => acc + Number(file.size || 0), 0);

  return (
    <div className="container mt-4">
      <div className="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1>CloudBox Enterprise</h1>
          <p>
            Bienvenido: <strong>{currentUser}</strong>
          </p>
        </div>
        <button className="btn btn-danger" onClick={logout}>
          Cerrar Sesión
        </button>
      </div>

      <div className="row mb-4">
        <div className="col-md-3">
          <div className="card metric-card p-3">
            <h6>Total Archivos</h6>
            <h2>{totalFiles}</h2>
          </div>
        </div>
        <div className="col-md-3">
          <div className="card metric-card p-3">
            <h6>PDFs</h6>
            <h2>{totalPdf}</h2>
          </div>
        </div>
        <div className="col-md-3">
          <div className="card metric-card p-3">
            <h6>Imágenes</h6>
            <h2>{totalImages}</h2>
          </div>
        </div>
        <div className="col-md-3">
          <div className="card metric-card p-3">
            <h6>Tamaño Total</h6>
            <h2>{totalSize}</h2>
          </div>
        </div>
      </div>

      <div className="card p-4 mb-4">
        <h4>Registrar Documento</h4>
        <div className="row">
          <div className="col-md-4">
            <input
              className="form-control"
              placeholder="Nombre"
              value={fileName}
              onChange={(e) => setFileName(e.target.value)}
            />
          </div>
          <div className="col-md-4">
            <input
              className="form-control"
              placeholder="Categoría"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
            />
          </div>
          <div className="col-md-2">
            <input
              className="form-control"
              placeholder="Tamaño"
              value={size}
              onChange={(e) => setSize(e.target.value)}
            />
          </div>
          <div className="col-md-2">
            <button className="btn btn-success w-100" onClick={createFile}>
              Guardar
            </button>
          </div>
        </div>
      </div>

      <div className="card p-4">
        <h4>Inventario Documental</h4>
        {loading ? (
          <p>Cargando...</p>
        ) : (
          <table className="table table-striped table-hover">
            <thead>
              <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>Categoría</th>
                <th>Tamaño</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              {files.map((file) => (
                <tr key={file.fileId}>
                  <td>{file.fileId}</td>
                  <td>{file.fileName}</td>
                  <td>{file.category}</td>
                  <td>{file.size}</td>
                  <td>
                    <button
                      className="btn btn-danger btn-sm"
                      onClick={() => deleteFile(file.fileId)}
                    >
                      Eliminar
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

export default Dashboard;
