import { z } from 'zod';

export const PaginationSchema = z.object({
  page: z.coerce.number().min(1).default(1),
  limit: z.coerce.number().min(5).max(50).default(10),
});

export const YearFilterSchema = z.coerce.number().int().min(2000).max(2100).optional();