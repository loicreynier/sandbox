#include "amgx_c.h"
#include <mpi.h>

MPI_Comm *AMGX_comm_;

void AMGX_print_callback_(const char *msg, int length) {
  int rank;
  MPI_Comm_rank(*AMGX_comm_, &rank);
  if (rank == 0) {
    printf("%s", msg);
  }
}

AMGX_RC AMGX_API AMGX_register_print_callback_(MPI_Comm *comm) {
  AMGX_comm_ = comm;
  AMGX_register_print_callback(&AMGX_print_callback_);
}

typedef struct {
  AMGX_matrix_handle A;
  AMGX_config_handle cfg;
  AMGX_vector_handle b, x, u, v;
  AMGX_resources_handle rsrc;
  AMGX_solver_handle solver;
} AMGXHandle;

MPI_Comm *MPI_Comm_f2c_(MPI_Fint f_comm) {
  MPI_Comm *c_comm;
  c_comm = malloc(sizeof(MPI_Comm));
  *c_comm = MPI_Comm_f2c(f_comm);
  return c_comm;
}

void AMGX_Solve(int n, const int *rows, const int *cols, const double *vals,
                double *b, double *x, const char *cfg_file, AMGX_Mode mode,
                int nproc, const int *devices, MPI_Comm *AMGX_comm) {

  int nrings, nmtx, nx, ny;

  AMGXHandle *ptr = (AMGXHandle *)calloc(1, sizeof(AMGXHandle));

  if (!ptr) {
    // TODO: better handling if allocation fails
    return;
  }

  AMGX_SAFE_CALL(AMGX_register_print_callback_(AMGX_comm));

  AMGX_SAFE_CALL(AMGX_initialize());
  AMGX_SAFE_CALL(AMGX_initialize_plugins());

  AMGX_SAFE_CALL(AMGX_config_create_from_file(&ptr->cfg, cfg_file));
  AMGX_SAFE_CALL(AMGX_config_get_default_number_of_rings(ptr->cfg, &nrings))

  // AMGX_resources_create_simple(&ptr->rsrc, ptr->cfg);
  AMGX_resources_create(&ptr->rsrc, ptr->cfg, AMGX_comm, 1, devices);
  MPI_Barrier(*AMGX_comm);

  AMGX_matrix_create(&ptr->A, ptr->rsrc, mode);
  AMGX_vector_create(&ptr->x, ptr->rsrc, mode);
  AMGX_vector_create(&ptr->b, ptr->rsrc, mode);
  AMGX_solver_create(&ptr->solver, ptr->rsrc, mode, ptr->cfg);
  MPI_Barrier(*AMGX_comm);

  // AMGX_matrix_upload_all(ptr->A, n, rows[n], 1, 1, rows, cols, vals, NULL);
  AMGX_matrix_upload_all_global(ptr->A, n * nproc, n, rows[n], 1, 1, rows, cols,
                                vals, NULL, nrings, nrings, NULL);
  MPI_Barrier(*AMGX_comm);

  AMGX_matrix_get_size(ptr->A, &nmtx, &nx, &ny);
  printf("System size\t::\t %d, %d, %d\n", nmtx, nx, ny);

  AMGX_vector_bind(ptr->x, ptr->A);
  AMGX_vector_bind(ptr->b, ptr->A);
  AMGX_vector_upload(ptr->x, n, 1, x);
  AMGX_vector_upload(ptr->b, n, 1, b);
  MPI_Barrier(*AMGX_comm);

  AMGX_solver_setup(ptr->solver, ptr->A);
  AMGX_solver_solve(ptr->solver, ptr->b, ptr->x);
  AMGX_vector_download(ptr->x, x);
  MPI_Barrier(*AMGX_comm);

  AMGX_solver_destroy(ptr->solver);
  AMGX_matrix_destroy(ptr->A);
  AMGX_vector_destroy(ptr->x);
  AMGX_vector_destroy(ptr->b);
  AMGX_resources_destroy(ptr->rsrc);

  AMGX_SAFE_CALL(AMGX_config_destroy(ptr->cfg));
  AMGX_SAFE_CALL(AMGX_finalize_plugins());
  AMGX_SAFE_CALL(AMGX_finalize());
}
