#include "amgx_c.h"

typedef struct {
  AMGX_matrix_handle A;
  AMGX_config_handle cfg;
  AMGX_vector_handle b, x, u, v;
  AMGX_resources_handle rsrc;
  AMGX_solver_handle solver;
} AMGXHandle;

void AMGXSolve(int n, const int *rows, const int *cols, const double *vals,
               double *b, double *x, const char *cfg_file, AMGX_Mode mode) {

  AMGXHandle *ptr = (AMGXHandle *)calloc(1, sizeof(AMGXHandle));

  if (!ptr) {
    // TODO: better handling if allocation fails
    return;
  }

  AMGX_SAFE_CALL(AMGX_initialize());
  AMGX_SAFE_CALL(AMGX_initialize_plugins());

  AMGX_SAFE_CALL(AMGX_config_create_from_file(&ptr->cfg, cfg_file));

  AMGX_resources_create_simple(&ptr->rsrc, ptr->cfg);
  AMGX_matrix_create(&ptr->A, ptr->rsrc, mode);
  AMGX_vector_create(&ptr->x, ptr->rsrc, mode);
  AMGX_vector_create(&ptr->b, ptr->rsrc, mode);
  AMGX_solver_create(&ptr->solver, ptr->rsrc, mode, ptr->cfg);

  AMGX_matrix_upload_all(ptr->A, n, rows[n], 1, 1, rows, cols, vals, NULL);

  AMGX_vector_bind(ptr->x, ptr->A);
  AMGX_vector_bind(ptr->b, ptr->A);
  AMGX_vector_upload(ptr->x, n, 1, x);
  AMGX_vector_upload(ptr->b, n, 1, b);

  AMGX_solver_setup(ptr->solver, ptr->A);
  AMGX_solver_solve(ptr->solver, ptr->b, ptr->x);
  AMGX_vector_download(ptr->x, x);

  AMGX_solver_destroy(ptr->solver);
  AMGX_matrix_destroy(ptr->A);
  AMGX_vector_destroy(ptr->x);
  AMGX_vector_destroy(ptr->b);
  AMGX_resources_destroy(ptr->rsrc);

  AMGX_SAFE_CALL(AMGX_config_destroy(ptr->cfg));
  AMGX_SAFE_CALL(AMGX_finalize_plugins());
  AMGX_SAFE_CALL(AMGX_finalize());
}
